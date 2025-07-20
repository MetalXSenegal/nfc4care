import React from 'react';
import { Phone, Mail, MapPin } from 'lucide-react';

interface ContactInfoProps {
  telephone?: string;
  email?: string;
  adresse?: string;
  className?: string;
  showIcons?: boolean;
  compact?: boolean;
}

const ContactInfo: React.FC<ContactInfoProps> = ({
  telephone,
  email,
  adresse,
  className = '',
  showIcons = true,
  compact = false
}) => {
  const formatPhone = (phone: string) => {
    const cleaned = phone.replace(/\D/g, '');
    if (cleaned.length === 10) {
      return cleaned.replace(/(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})/, '$1 $2 $3 $4 $5');
    }
    return phone;
  };

  const textSize = compact ? 'text-xs' : 'text-sm';
  const iconSize = compact ? 14 : 16;
  const spacing = compact ? 'space-y-1' : 'space-y-2';

  return (
    <div className={`${spacing} ${className}`}>
      {telephone && (
        <div className={`flex items-center ${textSize} text-gray-500`}>
          {showIcons && <Phone size={iconSize} className="mr-2 flex-shrink-0 text-gray-400" />}
          <a 
            href={`tel:${telephone}`}
            className="hover:text-blue-600 transition-colors flex items-center"
          >
            {formatPhone(telephone)}
          </a>
        </div>
      )}
      
      {email && (
        <div className={`flex items-center ${textSize} text-gray-500`}>
          {showIcons && <Mail size={iconSize} className="mr-2 flex-shrink-0 text-gray-400" />}
          <a 
            href={`mailto:${email}`}
            className="hover:text-blue-600 transition-colors truncate"
          >
            {email}
          </a>
        </div>
      )}
      
      {adresse && (
        <div className={`flex items-start ${textSize} text-gray-500`}>
          {showIcons && <MapPin size={iconSize} className="mr-2 flex-shrink-0 text-gray-400 mt-0.5" />}
          <span className="break-words">{adresse}</span>
        </div>
      )}
    </div>
  );
};

export default ContactInfo; 