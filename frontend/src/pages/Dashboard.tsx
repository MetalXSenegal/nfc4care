import React from 'react';
import { useNavigate } from 'react-router-dom';
import { Search, History, CreditCard, User, Clock, Users, FileText, TrendingUp } from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import StatsCard from '../components/dashboard/StatsCard';

const Dashboard: React.FC = () => {
  const navigate = useNavigate();
  const { currentDoctor } = useAuth();

  const getDoctorName = () => {
    if (currentDoctor) {
      return `${currentDoctor.prenom} ${currentDoctor.nom}`;
    }
    return 'Médecin';
  };

  const getGreeting = () => {
    const hour = new Date().getHours();
    if (hour < 12) return 'Bonjour';
    if (hour < 18) return 'Bon après-midi';
    return 'Bonsoir';
  };

  const stats = [
    {
      title: 'Patients aujourd\'hui',
      value: '12',
      icon: <Users className="h-5 w-5" />,
      color: 'blue' as const,
      trend: { value: '+3', positive: true }
    },
    {
      title: 'Consultations',
      value: '8',
      icon: <FileText className="h-5 w-5" />,
      color: 'green' as const,
      trend: { value: '+2', positive: true }
    },
    {
      title: 'Scans NFC',
      value: '15',
      icon: <CreditCard className="h-5 w-5" />,
      color: 'purple' as const,
      trend: { value: '+5', positive: true }
    }
  ];

  const quickActions = [
    {
      name: 'Rechercher un patient',
      description: 'Trouver rapidement un dossier',
      icon: Search,
      href: '/search',
      color: 'bg-blue-500',
      textColor: 'text-blue-500',
      gradient: 'from-blue-500 to-blue-600',
      image: '/assets/recherche.png',
      primary: true,
    },
    {
      name: 'Scanner NFC',
      description: 'Identifier par carte NFC',
      icon: CreditCard,
      href: '/nfc-scan',
      color: 'bg-green-500',
      textColor: 'text-green-500',
      gradient: 'from-green-500 to-green-600',
      image: '/assets/scan_nfc.png',
    },
    {
      name: 'Historique',
      description: 'Voir les consultations récentes',
      icon: History,
      href: '/history',
      color: 'bg-purple-500',
      textColor: 'text-purple-500',
      gradient: 'from-purple-500 to-purple-600',
      image: '/assets/historique.png',
    }
  ];

  const recentActivities = [
    {
      type: 'consultation',
      name: 'Sophie Laurent',
      time: 'Il y a 2 heures',
      icon: User,
      iconColor: 'bg-blue-100 text-blue-600',
      status: 'Terminée',
      statusColor: 'bg-green-100 text-green-800',
    },
    {
      type: 'scan',
      name: 'Marc Dupont',
      time: 'Il y a 4 heures',
      icon: CreditCard,
      iconColor: 'bg-green-100 text-green-600',
      status: 'Identifié',
      statusColor: 'bg-blue-100 text-blue-800',
    },
    {
      type: 'search',
      name: 'Recherche patient',
      time: 'Il y a 6 heures',
      icon: Search,
      iconColor: 'bg-purple-100 text-purple-600',
      status: 'Recherche',
      statusColor: 'bg-gray-100 text-gray-800',
    }
  ];

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 via-white to-gray-50 py-6 px-4 sm:px-6 lg:px-8">
      <div className="max-w-7xl mx-auto">
        {/* Bannière Hero améliorée */}
        <div className="mb-8 rounded-2xl overflow-hidden shadow-xl bg-gradient-to-br from-blue-500 via-blue-600 to-blue-700 relative">
          {/* Pattern décoratif */}
          <div className="absolute inset-0 opacity-10">
            <div className="absolute top-0 right-0 w-64 h-64 bg-white rounded-full -mr-32 -mt-32"></div>
            <div className="absolute bottom-0 left-0 w-48 h-48 bg-white rounded-full -ml-24 -mb-24"></div>
          </div>
          
          <div className="relative p-8 sm:p-10">
            <div className="flex flex-col sm:flex-row items-start sm:items-center gap-6">
              <div className="bg-white rounded-full p-4 shadow-2xl flex items-center justify-center ring-4 ring-white/20">
                <img
                  src="/assets/logo.png"
                  alt="NFC4Care Logo"
                  className="h-16 w-16 object-contain"
                  loading="eager"
                />
              </div>
              <div className="flex-1">
                <div className="flex items-center gap-3 mb-2">
                  <h1 className="text-3xl sm:text-4xl font-bold text-white">
                    {getGreeting()}, {getDoctorName()} 👋
                  </h1>
                </div>
                <p className="text-blue-100 text-lg mb-4">
                  Bienvenue dans votre espace médical sécurisé
                </p>
                <div className="flex items-center gap-2 text-blue-100">
                  <Clock className="h-5 w-5" />
                  <span className="text-sm font-medium">
                    {new Date().toLocaleDateString('fr-FR', {
                      weekday: 'long',
                      year: 'numeric',
                      month: 'long',
                      day: 'numeric'
                    })}
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Statistiques */}
        <div className="mb-8">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-xl font-bold text-gray-900">Aperçu</h2>
            <TrendingUp className="h-5 w-5 text-gray-400" />
          </div>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
            {stats.map((stat, index) => (
              <StatsCard
                key={index}
                title={stat.title}
                value={stat.value}
                icon={stat.icon}
                color={stat.color}
                trend={stat.trend}
              />
            ))}
          </div>
        </div>

        {/* Actions rapides améliorées */}
        <div className="mb-8">
          <div className="flex items-center justify-between mb-6">
            <div>
              <h2 className="text-xl font-bold text-gray-900">Actions rapides</h2>
              <p className="text-sm text-gray-500 mt-1">Accès rapide aux fonctionnalités principales</p>
            </div>
          </div>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
            {quickActions.map((action: any) => {
              const Icon = action.icon;
              return (
                <button
                  key={action.name}
                  onClick={() => navigate(action.href)}
                  className={`
                    group relative rounded-2xl shadow-lg overflow-hidden 
                    hover:shadow-2xl transition-all duration-300 text-left
                    transform hover:-translate-y-1 h-48
                    ${action.primary ? 'ring-2 ring-blue-400 ring-opacity-50' : ''}
                  `}
                >
                  {/* Background Image */}
                  <div className="absolute inset-0">
                    <img
                      src={action.image}
                      alt={action.name}
                      className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500"
                      loading="lazy"
                    />
                    {/* Overlay gradient for readability */}
                    <div className={`absolute inset-0 bg-gradient-to-br ${action.gradient} opacity-80 group-hover:opacity-70 transition-opacity duration-300`}></div>
                    {/* Additional dark overlay for text contrast */}
                    <div className="absolute inset-0 bg-black/20 group-hover:bg-black/10 transition-colors duration-300"></div>
                  </div>
                  
                  {/* Content */}
                  <div className="relative h-full flex flex-col justify-between p-6 text-white">
                    <div className="flex items-start justify-between gap-4">
                      <div className={`
                        p-3 rounded-xl bg-white/20 backdrop-blur-sm
                        shadow-lg group-hover:scale-110 transition-transform duration-300
                        flex-shrink-0 border border-white/30
                      `}>
                        <Icon className="h-6 w-6 text-white" />
                      </div>
                      {action.primary && (
                        <span className="text-yellow-300 text-xl drop-shadow-lg">⭐</span>
                      )}
                    </div>
                    
                    <div className="mt-auto">
                      <div className="flex items-center gap-2 mb-2">
                        <h3 className={`font-bold text-white drop-shadow-lg ${action.primary ? 'text-xl' : 'text-lg'}`}>
                          {action.name}
                        </h3>
                      </div>
                      <p className="text-sm text-white/90 drop-shadow-md leading-relaxed mb-3">{action.description}</p>
                      <div className="flex items-center text-xs font-semibold text-white/80 group-hover:text-white transition-colors">
                        <span>Accéder</span>
                        <svg className="ml-1 h-3 w-3 transform group-hover:translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                        </svg>
                      </div>
                    </div>
                  </div>
                </button>
              );
            })}
          </div>
        </div>

        {/* Section activité récente améliorée */}
        <div className="bg-white rounded-2xl shadow-lg border border-gray-100 overflow-hidden">
          <div className="px-6 py-5 bg-gradient-to-r from-gray-50 to-white border-b border-gray-100">
            <div className="flex items-center justify-between">
              <div>
                <h2 className="text-xl font-bold text-gray-900">Activité récente</h2>
                <p className="text-sm text-gray-500 mt-1">Dernières actions effectuées</p>
              </div>
              <button 
                onClick={() => navigate('/history')}
                className="text-sm font-medium text-blue-600 hover:text-blue-700 transition-colors"
              >
                Voir tout
              </button>
            </div>
          </div>
          <div className="p-6">
            <div className="space-y-3">
              {recentActivities.map((activity, index) => {
                const Icon = activity.icon;
                return (
                  <div
                    key={index}
                    className="flex items-center gap-4 p-4 rounded-xl hover:bg-gray-50 transition-colors duration-200 group cursor-pointer"
                    onClick={() => {
                      if (activity.type === 'consultation') navigate('/history');
                      else if (activity.type === 'scan') navigate('/nfc-scan');
                      else navigate('/search');
                    }}
                  >
                    <div className={`${activity.iconColor} h-12 w-12 rounded-xl flex items-center justify-center shadow-sm group-hover:scale-110 transition-transform duration-200`}>
                      <Icon className="h-6 w-6" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="font-semibold text-gray-900 group-hover:text-blue-600 transition-colors">
                        {activity.type === 'consultation' ? 'Consultation' : activity.type === 'scan' ? 'Scan NFC' : 'Recherche'} - {activity.name}
                      </p>
                      <p className="text-sm text-gray-500 mt-0.5">{activity.time}</p>
                    </div>
                    <span className={`inline-flex items-center px-3 py-1.5 text-xs font-semibold rounded-full ${activity.statusColor} shadow-sm`}>
                      {activity.status}
                    </span>
                    <svg className="h-5 w-5 text-gray-400 group-hover:text-blue-600 transition-colors opacity-0 group-hover:opacity-100" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                    </svg>
                  </div>
                );
              })}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;