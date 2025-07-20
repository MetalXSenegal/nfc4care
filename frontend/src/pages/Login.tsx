import React, { useState, useEffect } from 'react';
import { Mail, Lock, Activity, Shield, ArrowLeft, Smartphone } from 'lucide-react';
import Input from '../components/ui/Input';
import Button from '../components/ui/Button';
import { useAuth } from '../context/AuthContext';
import { useNavigate } from 'react-router-dom';

const Login: React.FC = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [twoFactorCode, setTwoFactorCode] = useState('');
  const [error, setError] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [requires2FA, setRequires2FA] = useState(false);
  const [loginAttempts, setLoginAttempts] = useState(0);
  const [isLocked, setIsLocked] = useState(false);
  const [lockoutTime, setLockoutTime] = useState(0);
  const { login, verify2FA } = useAuth();
  const navigate = useNavigate();

  // Vérifier si l'utilisateur est verrouillé
  useEffect(() => {
    const lastAttempt = localStorage.getItem('lastLoginAttempt');
    const attempts = localStorage.getItem('loginAttempts');
    
    if (lastAttempt && attempts) {
      const timeSinceLastAttempt = Date.now() - parseInt(lastAttempt);
      const attemptsCount = parseInt(attempts);
      
      if (attemptsCount >= 5 && timeSinceLastAttempt < 15 * 60 * 1000) { // 15 minutes
        setIsLocked(true);
        setLockoutTime(Math.ceil((15 * 60 * 1000 - timeSinceLastAttempt) / 1000));
      } else if (timeSinceLastAttempt >= 15 * 60 * 1000) {
        // Reset après 15 minutes
        localStorage.removeItem('loginAttempts');
        localStorage.removeItem('lastLoginAttempt');
        setLoginAttempts(0);
        setIsLocked(false);
      } else {
        setLoginAttempts(attemptsCount);
      }
    }
  }, []);

  // Timer pour le verrouillage
  useEffect(() => {
    if (isLocked && lockoutTime > 0) {
      const timer = setInterval(() => {
        setLockoutTime(prev => {
          if (prev <= 1) {
            setIsLocked(false);
            localStorage.removeItem('loginAttempts');
            localStorage.removeItem('lastLoginAttempt');
            setLoginAttempts(0);
            return 0;
          }
          return prev - 1;
        });
      }, 1000);
      return () => clearInterval(timer);
    }
  }, [isLocked, lockoutTime]);

  const handleLoginAttempt = () => {
    const attempts = loginAttempts + 1;
    setLoginAttempts(attempts);
    localStorage.setItem('loginAttempts', attempts.toString());
    localStorage.setItem('lastLoginAttempt', Date.now().toString());
    
    if (attempts >= 5) {
      setIsLocked(true);
      setLockoutTime(15 * 60); // 15 minutes
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault(); // Empêcher l'actualisation dès le début
    setError('');
    setIsLoading(true);

    if (isLocked) {
      setError(`Compte temporairement verrouillé. Réessayez dans ${Math.floor(lockoutTime / 60)}:${(lockoutTime % 60).toString().padStart(2, '0')}`);
      setIsLoading(false);
      return;
    }

    try {
      console.log('🔐 Début de la tentative de connexion...');
      console.log('📧 Email:', email);
      console.log('🔑 Mot de passe fourni:', password ? 'Oui' : 'Non');
      
      const result = await login(email, password);
      
      console.log('📋 Résultat de la connexion:', result);
      
      if (result.success) {
        if (result.requires2FA) {
          console.log('🔐 2FA requis, affichage du formulaire 2FA');
          setRequires2FA(true);
          setError('');
        } else {
          console.log('✅ Connexion réussie, vérification du stockage...');
          
          // Attendre un peu pour s'assurer que le stockage est terminé
          await new Promise(resolve => setTimeout(resolve, 200));
          
          // Vérifier que le token est bien stocké
          const storedToken = localStorage.getItem('authToken');
          const storedData = localStorage.getItem('doctorData');
          
          console.log('🔍 Vérification du stockage après connexion:');
          console.log('  - Token stocké:', storedToken ? 'Oui' : 'Non');
          console.log('  - Données stockées:', storedData ? 'Oui' : 'Non');
          console.log('🔑 TOKEN DANS LOCALSTORAGE (Login):', storedToken ? `${storedToken.substring(0, 20)}...` : 'Aucun');
          console.log('📋 DONNÉES DANS LOCALSTORAGE (Login):', storedData ? 'Présentes' : 'Absentes');
          
          if (storedToken && storedData) {
            console.log('✅ Token et données stockés, redirection vers le dashboard');
            console.log('🎯 REDIRECTION VERS: /dashboard');
            
            // Redirection immédiate sans setTimeout
            navigate('/dashboard', { replace: true });
          } else {
            console.log('❌ Token ou données non stockés, erreur de stockage');
            console.log('🔍 Détails du problème:');
            console.log('  - Token présent:', !!storedToken);
            console.log('  - Données présentes:', !!storedData);
            console.log('🔍 Contenu localStorage complet:');
            Object.keys(localStorage).forEach(key => {
              console.log(`  ${key}:`, localStorage.getItem(key));
            });
            setError('Erreur lors du stockage de la session. Veuillez réessayer.');
          }
        }
      } else {
        handleLoginAttempt();
        setError(result.error || 'Identifiants incorrects. Veuillez réessayer.');
      }
    } catch (err) {
      console.error('❌ Erreur lors de la connexion:', err);
      handleLoginAttempt();
      setError('Une erreur est survenue. Veuillez réessayer.');
    } finally {
      setIsLoading(false);
    }
  };

  const handle2FASubmit = async (e: React.FormEvent) => {
    e.preventDefault(); // Empêcher l'actualisation dès le début
    setError('');
    setIsLoading(true);

    try {
      console.log('🔐 Début de la vérification 2FA...');
      console.log('🔢 Code 2FA:', twoFactorCode);
      
      const result = await verify2FA(twoFactorCode);
      
      console.log('📋 Résultat de la vérification 2FA:', result);
      
      if (result.success) {
        console.log('✅ 2FA réussie, vérification du stockage...');
        
        // Attendre un peu pour s'assurer que le stockage est terminé
        await new Promise(resolve => setTimeout(resolve, 200));
        
        // Vérifier que le token est bien stocké
        const storedToken = localStorage.getItem('authToken');
        const storedData = localStorage.getItem('doctorData');
        
        console.log('🔍 Vérification du stockage après 2FA:');
        console.log('  - Token stocké:', storedToken ? 'Oui' : 'Non');
        console.log('  - Données stockées:', storedData ? 'Oui' : 'Non');
        console.log('🔑 TOKEN DANS LOCALSTORAGE (2FA):', storedToken ? `${storedToken.substring(0, 20)}...` : 'Aucun');
        console.log('📋 DONNÉES DANS LOCALSTORAGE (2FA):', storedData ? 'Présentes' : 'Absentes');
        
        if (storedToken && storedData) {
          console.log('✅ Token et données stockés après 2FA, redirection vers le dashboard');
          console.log('🎯 REDIRECTION VERS: /dashboard (après 2FA)');
          
          // Redirection immédiate sans setTimeout
          navigate('/dashboard', { replace: true });
        } else {
          console.log('❌ Token ou données non stockés après 2FA, erreur de stockage');
          console.log('🔍 Détails du problème (2FA):');
          console.log('  - Token présent:', !!storedToken);
          console.log('  - Données présentes:', !!storedData);
          console.log('🔍 Contenu localStorage complet (2FA):');
          Object.keys(localStorage).forEach(key => {
            console.log(`  ${key}:`, localStorage.getItem(key));
          });
          setError('Erreur lors du stockage de la session après 2FA. Veuillez réessayer.');
        }
      } else {
        setError(result.error || 'Code 2FA invalide. Veuillez réessayer.');
      }
    } catch (err) {
      console.error('❌ Erreur lors de la vérification 2FA:', err);
      setError('Une erreur est survenue lors de la vérification.');
    } finally {
      setIsLoading(false);
    }
  };

  const handleBackToLogin = () => {
    setRequires2FA(false);
    setTwoFactorCode('');
    setError('');
  };

  const formatTime = (seconds: number) => {
    const minutes = Math.floor(seconds / 60);
    const remainingSeconds = seconds % 60;
    return `${minutes}:${remainingSeconds.toString().padStart(2, '0')}`;
  };

  if (requires2FA) {
    return (
      <div className="min-h-screen bg-gray-50 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
        <div className="sm:mx-auto sm:w-full sm:max-w-md">
          <div className="flex justify-center">
            <Shield className="h-12 w-12 text-blue-600" />
          </div>
          <h2 className="mt-4 text-center text-3xl font-extrabold text-gray-900">
            Authentification à double facteur
          </h2>
          <p className="mt-2 text-center text-sm text-gray-600">
            Entrez le code de votre application d'authentification
          </p>
        </div>

        <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
          <div className="bg-white py-8 px-4 shadow sm:rounded-lg sm:px-10">
            {error && (
              <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-md mb-4">
                {error}
              </div>
            )}
            
            <form className="space-y-6" onSubmit={handle2FASubmit}>
              <div className="text-center">
                <div className="mx-auto w-16 h-16 bg-blue-100 rounded-full flex items-center justify-center mb-4">
                  <Smartphone className="h-8 w-8 text-blue-600" />
                </div>
                <p className="text-sm text-gray-600 mb-4">
                  Un code de vérification a été envoyé à votre application d'authentification
                </p>
              </div>

              <Input
                label="Code de vérification"
                type="text"
                id="2fa-code"
                value={twoFactorCode}
                onChange={(e) => setTwoFactorCode(e.target.value.replace(/\D/g, '').slice(0, 6))}
                placeholder="123456"
                required
                maxLength={6}
                pattern="[0-9]{6}"
                icon={<Shield size={20} />}
              />

              <div className="flex space-x-3">
                <Button
                  type="button"
                  variant="outline"
                  onClick={handleBackToLogin}
                  icon={<ArrowLeft size={16} />}
                  className="flex-1"
                >
                  Retour
                </Button>
                <Button
                  type="submit"
                  loading={isLoading}
                  className="flex-1"
                >
                  Vérifier
                </Button>
              </div>
            </form>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
      <div className="sm:mx-auto sm:w-full sm:max-w-md">
        <div className="flex justify-center">
          <Activity className="h-12 w-12 text-blue-600" />
        </div>
        <h2 className="mt-4 text-center text-3xl font-extrabold text-gray-900">
          NFC4Care
        </h2>
        <p className="mt-2 text-center text-sm text-gray-600">
          Gestion médicale sécurisée avec blockchain
        </p>
      </div>

      <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
        <div className="bg-white py-8 px-4 shadow sm:rounded-lg sm:px-10">
          {error && (
            <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-md mb-4">
              {error}
            </div>
          )}

          {isLocked && (
            <div className="bg-yellow-50 border border-yellow-200 text-yellow-700 px-4 py-3 rounded-md mb-4">
              <p className="font-medium">Compte temporairement verrouillé</p>
              <p className="text-sm">Temps restant: {formatTime(lockoutTime)}</p>
            </div>
          )}
          
          <form className="space-y-6" onSubmit={handleSubmit}>
            <Input
              label="Adresse email"
              type="email"
              id="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="docteur@example.com"
              required
              disabled={isLocked}
              icon={<Mail size={20} />}
            />

            <Input
              label="Mot de passe"
              type="password"
              id="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              disabled={isLocked}
              icon={<Lock size={20} />}
            />

            <div className="flex items-center justify-between">
              <div className="flex items-center">
                <input
                  id="remember_me"
                  name="remember_me"
                  type="checkbox"
                  className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
                  disabled={isLocked}
                />
                <label htmlFor="remember_me" className="ml-2 block text-sm text-gray-900">
                  Se souvenir de moi
                </label>
              </div>

              <div className="text-sm">
                <a href="#" className="font-medium text-blue-600 hover:text-blue-500">
                  Mot de passe oublié?
                </a>
              </div>
            </div>

            <div>
              <Button
                type="submit"
                fullWidth
                loading={isLoading}
                size="lg"
                disabled={isLocked}
              >
                Se connecter
              </Button>
            </div>
          </form>

          <div className="mt-6">
            <div className="relative">
              <div className="absolute inset-0 flex items-center">
                <div className="w-full border-t border-gray-300" />
              </div>
              <div className="relative flex justify-center text-sm">
                <span className="px-2 bg-white text-gray-500">
                  Compte de test
                </span>
              </div>
            </div>
            <div className="mt-4 text-center text-xs text-gray-500">
              <p>Email: doctor@example.com</p>
              <p>Mot de passe: password</p>
            </div>
          </div>

          {loginAttempts > 0 && !isLocked && (
            <div className="mt-4 text-center text-xs text-orange-600">
              Tentatives restantes: {5 - loginAttempts}
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default Login;