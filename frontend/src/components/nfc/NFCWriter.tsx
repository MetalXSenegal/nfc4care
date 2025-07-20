import React, { useState } from 'react';
import { Wifi, CheckCircle, AlertCircle, Loader } from 'lucide-react';

// Types NFC globaux
declare global {
  interface Window {
    NDEFReader: any;
    NDEFWriter: any;
  }
}

interface NFCWriterProps {
  patientId: string;
  patientName: string;
  nfcId: string;
  onSuccess?: () => void;
  onError?: (error: string) => void;
}

const NFCWriter: React.FC<NFCWriterProps> = ({ 
  patientId, 
  patientName, 
  nfcId, 
  onSuccess, 
  onError 
}) => {
  const [isWriting, setIsWriting] = useState(false);
  const [writeStatus, setWriteStatus] = useState<'idle' | 'writing' | 'success' | 'error'>('idle');
  const [message, setMessage] = useState('Prêt à écrire la carte NFC');

  const writeNFCTag = async () => {
    if (!('NDEFWriter' in window)) {
      setWriteStatus('error');
      setMessage('Écriture NFC non supportée sur ce navigateur');
      onError?.('NFC non supporté');
      return;
    }

    try {
      setIsWriting(true);
      setWriteStatus('writing');
      setMessage('Approchez une carte NFC vierge...');

      const ndef = new (window as any).NDEFWriter();
      
      // Préparer les données à écrire
      const nfcData = {
        nfcId: nfcId,
        patientId: patientId,
        patientName: patientName,
        timestamp: new Date().toISOString(),
        type: 'patient_card'
      };

      const textEncoder = new TextEncoder();
      const jsonString = JSON.stringify(nfcData);
      const encodedData = textEncoder.encode(jsonString);

      // Créer le message NDEF
      const ndefMessage = {
        records: [
          {
            recordType: "text",
            data: encodedData,
            mediaType: "application/json"
          }
        ]
      };

      // Écrire sur la carte NFC
      await ndef.write(ndefMessage);

      setWriteStatus('success');
      setMessage(`Carte NFC écrite avec succès pour ${patientName}`);
      onSuccess?.();

      // Réinitialiser après 3 secondes
      setTimeout(() => {
        setWriteStatus('idle');
        setMessage('Prêt à écrire la carte NFC');
        setIsWriting(false);
      }, 3000);

    } catch (error) {
      console.error('Erreur d\'écriture NFC:', error);
      setWriteStatus('error');
      setMessage('Erreur d\'écriture. Vérifiez la carte et réessayez.');
      onError?.(error instanceof Error ? error.message : 'Erreur inconnue');
      
      setTimeout(() => {
        setWriteStatus('idle');
        setMessage('Prêt à écrire la carte NFC');
        setIsWriting(false);
      }, 3000);
    }
  };

  const handleWriteStart = () => {
    writeNFCTag();
  };

  return (
    <div className="bg-white rounded-lg shadow-md p-6 border">
      <div className="flex items-center justify-between mb-4">
        <h3 className="text-lg font-semibold text-gray-900">Écrire Carte NFC</h3>
        <div className="text-sm text-gray-500">
          ID: {nfcId}
        </div>
      </div>

      <div className="mb-4">
        <p className="text-sm text-gray-600 mb-2">
          <strong>Patient:</strong> {patientName}
        </p>
        <p className="text-sm text-gray-600">
          <strong>Données à écrire:</strong> Informations patient et identifiant unique
        </p>
      </div>

      <div className="flex flex-col items-center mb-6">
        <div 
          className={`
            w-24 h-24 rounded-full flex items-center justify-center mb-4
            ${writeStatus === 'idle' ? 'bg-blue-100' : ''}
            ${writeStatus === 'writing' ? 'bg-yellow-100' : ''}
            ${writeStatus === 'success' ? 'bg-green-100' : ''}
            ${writeStatus === 'error' ? 'bg-red-100' : ''}
          `}
        >
          {writeStatus === 'success' ? (
            <CheckCircle size={32} className="text-green-600" />
          ) : writeStatus === 'error' ? (
            <AlertCircle size={32} className="text-red-600" />
          ) : writeStatus === 'writing' ? (
            <Loader size={32} className="text-yellow-600 animate-spin" />
          ) : (
            <Wifi size={32} className="text-blue-600" />
          )}
        </div>
        
        <p className="text-sm text-gray-600 text-center">{message}</p>
      </div>

      <button
        onClick={handleWriteStart}
        disabled={isWriting}
        className={`
          w-full py-2 px-4 rounded-md transition-colors
          ${isWriting 
            ? 'bg-gray-400 cursor-not-allowed' 
            : 'bg-blue-600 hover:bg-blue-700'
          }
          text-white font-medium
        `}
      >
        {isWriting ? 'Écriture en cours...' : 'Écrire la carte NFC'}
      </button>

      <div className="mt-4 bg-yellow-50 rounded-lg p-3 border border-yellow-200">
        <p className="text-xs text-yellow-800">
          <strong>Important:</strong> Utilisez une carte NFC vierge ou effacez-la avant l'écriture.
        </p>
      </div>
    </div>
  );
};

export default NFCWriter; 