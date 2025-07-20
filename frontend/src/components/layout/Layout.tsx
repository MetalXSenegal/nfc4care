import React from 'react';
import { Outlet } from 'react-router-dom';
import Sidebar from './Sidebar';
import MobileHeader from './MobileHeader';
import BottomNavigation from './BottomNavigation';

const Layout: React.FC = () => {
  return (
    <div className="min-h-screen bg-gray-50">
      {/* Desktop Sidebar */}
      <div className="hidden lg:block">
        <Sidebar />
      </div>
      
      {/* Mobile Header */}
      <div className="lg:hidden">
        <MobileHeader />
      </div>
      
      {/* Main Content */}
      <div className="lg:ml-64">
        <main className="min-h-screen pb-20 lg:pb-0">
          <Outlet />
        </main>
      </div>
      
      {/* Mobile Bottom Navigation */}
      <div className="lg:hidden">
        <BottomNavigation />
      </div>
    </div>
  );
};

export default Layout;