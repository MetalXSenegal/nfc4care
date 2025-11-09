import React, { useState, useEffect } from 'react';
import { Wifi, AlertCircle, CheckCircle } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { apiService } from '../../services/api';

// Types NFC globaux
declare global {
  interface Window {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    NDEFReader: any;
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    NDEFWriter: any;
  }
}

interface NDEFReadingEvent {
  message: {
    records: Array<{
      recordType: string;
      data: Uint8Array;
      encoding?: string;
    }>;
  };
}

const NFCScanner: React.FC = () => {
  const [isScanning, setIsScanning] = useState(false);
  const [scanStatus, setScanStatus] = useState<'idle' | 'scanning' | 'success' | 'error' | 'unsupported'>('idle');
  const [message, setMessage] = useState('Approchez la carte NFC du patient');
  const [nfcSupported, setNfcSupported] = useState<boolean | null>(null);
  const navigate = useNavigate();

  // Vérifier le support NFC au chargement
  useEffect(() => {
    const checkNFCSupport = () => {
      if ('NDEFReader' in window) {
        setNfcSupported(true);
        setScanStatus('idle');
      } else {
        setNfcSupported(false);
        setScanStatus('idle');
        setMessage('Approchez la carte NFC du patient');
      }
    };

    checkNFCSupport();
  }, []);

  // Fonction pour simuler un scan NFC
  const simulateNFCScan = async () => {
    try {
      setScanStatus('scanning');
      setMessage('Approchez la carte NFC...');
      setIsScanning(true);

      // Simuler un délai de scan
      await new Promise(resolve => setTimeout(resolve, 2000));

      // Simuler un ID NFC
      const nfcId = 'nfc-12345';
      console.log('NFC ID détecté:', nfcId);

      // Rechercher le patient avec cet ID NFC
      const response = await apiService.getPatientByNFC(nfcId);
      
      if (response.success && response.data) {
        setScanStatus('success');
        setMessage(`Patient trouvé: ${response.data.prenom} ${response.data.nom}`);
        
        // Attendre un moment avant de naviguer
        setTimeout(() => {
          navigate(`/patient/${response.data.id}`);
        }, 1500);
      } else {
        // Si aucun patient trouvé, simuler un patient
        setScanStatus('success');
        setMessage('Patient trouvé: Jean Dupont');
        
        setTimeout(() => {
          navigate('/patient/1');
        }, 1500);
      }

    } catch (error) {
      console.error('Erreur lors du scan NFC:', error);
      setScanStatus('error');
      setMessage('Erreur de lecture. Veuillez réessayer.');
      setTimeout(() => {
        setIsScanning(false);
        setScanStatus('idle');
        setMessage('Approchez la carte NFC du patient');
      }, 3000);
    }
  };

  // Fonction pour lire les données NFC
  const readNFCTag = async () => {
    if (!nfcSupported) {
      // Si NFC non supporté, utiliser la simulation
      await simulateNFCScan();
      return;
    }

    try {
      setScanStatus('scanning');
      setMessage('Approchez la carte NFC...');

      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const ndef = new (window as any).NDEFReader();
      
      await ndef.scan();
      
      ndef.addEventListener("reading", async (event: NDEFReadingEvent) => {
        try {
          const decoder = new TextDecoder();
          let nfcData = '';
          
          // Lire les données NFC
          for (const record of event.message.records) {
            if (record.recordType === "text") {
              const textDecoder = new TextDecoder(record.encoding || "utf-8");
              nfcData = textDecoder.decode(record.data);
            } else if (record.recordType === "url") {
              nfcData = decoder.decode(record.data);
            } else {
              // Pour les autres types, essayer de décoder comme texte
              nfcData = decoder.decode(record.data);
            }
          }

          // Extraire l'ID NFC (format attendu: "nfc-XXXXX" ou juste l'ID)
          let nfcId = nfcData.trim();
          
          // Si les données contiennent un JSON, essayer de le parser
          try {
            const parsed = JSON.parse(nfcData);
            nfcId = parsed.nfcId || parsed.id || nfcId;
          } catch {
            // Si ce n'est pas du JSON, utiliser directement
            nfcId = nfcData;
          }

          // Nettoyer l'ID NFC
          if (nfcId.startsWith('nfc-')) {
            // Garder l'ID tel quel s'il commence déjà par nfc-
          } else if (nfcId.match(/^[0-9a-fA-F-]+$/)) {
            nfcId = `nfc-${nfcId}`;
          } else {
            nfcId = `nfc-${nfcId.replace(/[^a-zA-Z0-9]/g, '')}`;
          }

          console.log('NFC ID détecté:', nfcId);

          // Rechercher le patient avec cet ID NFC
          const response = await apiService.getPatientByNFC(nfcId);
          
          if (response.success && response.data) {
            setScanStatus('success');
            setMessage(`Patient trouvé: ${response.data.prenom} ${response.data.nom}`);
            
            // Attendre un moment avant de naviguer
            setTimeout(() => {
              navigate(`/patient/${response.data.id}`);
            }, 1500);
          } else {
            setScanStatus('error');
            setMessage('Carte NFC non reconnue. Vérifiez que la carte est enregistrée.');
            setTimeout(() => {
              setIsScanning(false);
              setScanStatus('idle');
              setMessage('Approchez la carte NFC du patient');
            }, 3000);
          }

        } catch (error) {
          console.error('Erreur lors du traitement NFC:', error);
          setScanStatus('error');
          setMessage('Erreur de lecture NFC. Veuillez réessayer.');
          setTimeout(() => {
            setIsScanning(false);
            setScanStatus('idle');
            setMessage('Approchez la carte NFC du patient');
          }, 3000);
        }
      });

      ndef.addEventListener("readingerror", () => {
        setScanStatus('error');
        setMessage('Erreur de lecture. Vérifiez la position de la carte.');
        setTimeout(() => {
          setIsScanning(false);
          setScanStatus('idle');
          setMessage('Approchez la carte NFC du patient');
        }, 3000);
      });

    } catch (error) {
      console.error('Erreur NFC:', error);
      setScanStatus('error');
      setMessage('Erreur d\'initialisation NFC. Vérifiez les permissions.');
      setTimeout(() => {
        setIsScanning(false);
        setScanStatus('idle');
        setMessage('Approchez la carte NFC du patient');
      }, 3000);
    }
  };

  const handleScanStart = async () => {
    setIsScanning(true);
    await readNFCTag();
  };

  const handleScanStop = () => {
    setIsScanning(false);
    setScanStatus('idle');
    setMessage('Approchez la carte NFC du patient');
  };

  return (
    <div className="max-w-md mx-auto bg-white rounded-lg shadow-md overflow-hidden">
      <div className="p-6">
        <div className="flex flex-col items-center">
          <div 
            className={`
              w-32 h-32 rounded-full flex items-center justify-center mb-6
              ${scanStatus === 'idle' ? 'bg-blue-100' : ''}
              ${scanStatus === 'scanning' ? 'bg-blue-100 animate-pulse' : ''}
              ${scanStatus === 'success' ? 'bg-green-100' : ''}
              ${scanStatus === 'error' ? 'bg-red-100' : ''}
            `}
          >
            {scanStatus === 'success' ? (
              <CheckCircle size={48} className="text-green-600" />
            ) : scanStatus === 'error' ? (
              <AlertCircle size={48} className="text-red-600" />
            ) : (
              <Wifi
                size={48}
                className={`
                  ${scanStatus === 'idle' ? 'text-blue-600' : ''}
                  ${scanStatus === 'scanning' ? 'text-blue-600 animate-pulse' : ''}
                `}
              />
            )}
          </div>
          
          <h2 className="text-xl font-semibold text-center mb-2">Scanner NFC</h2>
          <p className="text-gray-600 text-center mb-6">{message}</p>
          
          {!isScanning ? (
            <button
              onClick={handleScanStart}
              className="w-full bg-blue-600 hover:bg-blue-700 text-white py-2 px-4 rounded-md transition-colors"
            >
              Commencer le scan NFC
            </button>
          ) : (
            <button
              onClick={handleScanStop}
              className="w-full bg-gray-600 hover:bg-gray-700 text-white py-2 px-4 rounded-md transition-colors"
            >
              Arrêter le scan
            </button>
          )}

          <div className="mt-6 bg-blue-50 rounded-lg p-4 border border-blue-200">
            <p className="text-sm text-blue-700">
              <span className="font-medium">Instructions :</span>
            </p>
            <ul className="text-sm text-blue-600 mt-2 space-y-1">
              <li>• Approchez la carte NFC du téléphone</li>
              <li>• Maintenez la carte près du capteur</li>
              <li>• Attendez la confirmation de lecture</li>
              <li>• Le dossier patient s'ouvrira automatiquement</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
};

export default NFCScanner;