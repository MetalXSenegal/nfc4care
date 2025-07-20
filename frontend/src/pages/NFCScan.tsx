import React from 'react';
import NFCScanner from '../components/nfc/NFCScanner';

const NFCScan: React.FC = () => {
  return (
    <div className="py-6 px-4 sm:px-6 lg:px-8">
      <div className="max-w-3xl mx-auto">
        <div className="text-center mb-8">
          <h1 className="text-2xl font-bold text-gray-900">Scanner NFC Patient</h1>
          <p className="mt-1 text-sm text-gray-500">
            Utilisez la technologie NFC pour identifier rapidement un patient et accéder à son dossier médical
          </p>
        </div>
        
        <NFCScanner />
        
        <div className="mt-8 grid grid-cols-1 md:grid-cols-2 gap-6">
          <div className="bg-green-50 rounded-lg p-4 border border-green-200">
            <h3 className="font-medium text-green-800 mb-2">✅ Fonctionnalités NFC</h3>
            <ul className="text-sm text-green-700 space-y-1">
              <li>• Lecture de cartes NFC compatibles</li>
              <li>• Identification automatique des patients</li>
              <li>• Accès sécurisé aux dossiers</li>
              <li>• Intégration blockchain Cardano</li>
            </ul>
          </div>
          
          <div className="bg-blue-50 rounded-lg p-4 border border-blue-200">
            <h3 className="font-medium text-blue-800 mb-2">🔧 Compatibilité</h3>
            <ul className="text-sm text-blue-700 space-y-1">
              <li>• Chrome/Edge sur Android</li>
              <li>• Safari sur iOS (limité)</li>
              <li>• Connexion HTTPS requise</li>
              <li>• NFC activé sur l'appareil</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
};

export default NFCScan;