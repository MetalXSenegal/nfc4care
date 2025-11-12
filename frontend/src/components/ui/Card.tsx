import React, { useState } from 'react';

interface CardProps {
  children: React.ReactNode;
  className?: string;
  hoverable?: boolean;
  image?: string;
  imageAlt?: string;
}

const Card: React.FC<CardProps> = ({
  children,
  className = '',
  hoverable = false,
  image,
  imageAlt = 'Card image',
}) => {
  const [imageError, setImageError] = useState(false);

  return (
    <div
      className={`
        bg-white rounded-lg shadow-md overflow-hidden
        ${hoverable ? 'hover:shadow-lg transition-shadow duration-300 cursor-pointer' : ''}
        ${className}
      `}
    >
      {image && !imageError && (
        <div className="w-full h-48 overflow-hidden bg-gradient-to-br from-gray-100 to-gray-200 relative">
          <img
            src={image}
            alt={imageAlt}
            className="w-full h-full object-cover hover:scale-105 transition-transform duration-300"
            loading="lazy"
            onError={() => setImageError(true)}
          />
        </div>
      )}
      {image && imageError && (
        <div className="w-full h-48 flex items-center justify-center bg-gradient-to-br from-blue-100 to-blue-200">
          <svg className="w-16 h-16 text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
          </svg>
        </div>
      )}
      <div className="p-6">{children}</div>
    </div>
  );
};

export default Card;
