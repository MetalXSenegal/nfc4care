import React from 'react';
import { Link, useLocation } from 'react-router-dom';
import { 
  Home, 
  Search, 
  History, 
  Users, 
  User
} from 'lucide-react';

const BottomNavigation: React.FC = () => {
  const location = useLocation();

  const navigation = [
    { name: 'Accueil', href: '/dashboard', icon: Home },
    { name: 'Rechercher', href: '/search', icon: Search, primary: true },
    { name: 'Historique', href: '/history', icon: History },
    { name: 'NFC', href: '/nfc-scan', icon: Users },
    { name: 'Profil', href: '/profile', icon: User },
  ];

  const isActive = (path: string) => {
    return location.pathname === path;
  };

  return (
    <nav className="fixed bottom-0 left-0 right-0 z-40 bg-gradient-to-t from-blue-500 to-blue-600 border-t border-blue-300 shadow-lg">
      <div className="flex items-center justify-around px-2 py-2">
        {navigation.map((item) => {
          const Icon = item.icon;
          const active = isActive(item.href);
          
          return (
            <Link
              key={item.name}
              to={item.href}
              className={`
                flex flex-col items-center justify-center px-3 py-2 rounded-lg transition-all duration-200 relative
                ${active 
                  ? 'text-white bg-white/20' 
                  : 'text-blue-100 hover:text-white hover:bg-white/10'
                }
                ${item.primary && active ? 'bg-white/30' : ''}
              `}
            >
              {item.primary && (
                <div className="absolute -top-1 -right-1 w-2 h-2 bg-white rounded-full shadow-lg"></div>
              )}
              <Icon 
                size={item.primary ? 22 : 20} 
                className={`mb-1 ${active ? 'text-white' : 'text-blue-100'}`} 
              />
              <span className={`text-xs font-medium ${active ? 'text-white' : 'text-blue-100'} ${item.primary ? 'font-semibold' : ''}`}>
                {item.name}
              </span>
            </Link>
          );
        })}
      </div>
    </nav>
  );
};

export default BottomNavigation; 