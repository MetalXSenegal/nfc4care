import React, { ReactNode } from 'react';

interface StatsCardProps {
  title: string;
  value: string | number;
  icon: ReactNode;
  color?: 'blue' | 'green' | 'purple' | 'orange';
  onClick?: () => void;
  trend?: {
    value: string | number;
    positive: boolean;
  };
}

const StatsCard: React.FC<StatsCardProps> = ({
  title,
  value,
  icon,
  color = 'blue',
  onClick,
  trend
}) => {
  const colorClasses = {
    blue: 'bg-blue-50 text-blue-600',
    green: 'bg-green-50 text-green-600',
    purple: 'bg-purple-50 text-purple-600',
    orange: 'bg-orange-50 text-orange-600'
  };

  return (
    <div 
      className={`bg-white rounded-lg shadow p-4 ${onClick ? 'cursor-pointer hover:shadow-md transition-shadow' : ''}`}
      onClick={onClick}
    >
      <div className="flex items-center justify-between">
        <h3 className="text-sm font-medium text-gray-500">{title}</h3>
        <div className={`p-2 rounded-md ${colorClasses[color]}`}>
          {icon}
        </div>
      </div>
      <div className="mt-3">
        <p className="text-2xl font-bold text-gray-900">{value}</p>
        {trend && (
          <p className={`text-sm ${trend.positive ? 'text-green-600' : 'text-red-600'} flex items-center mt-1`}>
            <span className={`mr-1 ${trend.positive ? 'rotate-0' : 'rotate-180'}`}>
              ▲
            </span>
            {trend.value} {trend.positive ? 'plus' : 'moins'} que le mois dernier
          </p>
        )}
      </div>
    </div>
  );
};

export default StatsCard;