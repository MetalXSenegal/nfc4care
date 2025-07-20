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
    <nav className="fixed bottom-0 left-0 right-0 z-40 bg-white border-t border-gray-200 shadow-lg">
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
                  ? 'text-blue-600 bg-blue-50' 
                  : 'text-gray-600 hover:text-gray-900 hover:bg-gray-50'
                }
                ${item.primary && active ? 'bg-blue-100' : ''}
              `}
            >
              {item.primary && (
                <div className="absolute -top-1 -right-1 w-2 h-2 bg-blue-500 rounded-full"></div>
              )}
              <Icon 
                size={item.primary ? 22 : 20} 
                className={`mb-1 ${active ? 'text-blue-600' : 'text-gray-500'}`} 
              />
              <span className={`text-xs font-medium ${item.primary ? 'font-semibold' : ''}`}>
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