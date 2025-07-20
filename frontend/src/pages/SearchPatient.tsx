import React, { useState, useEffect, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { Search, Filter, X, User, Calendar, Phone, Mail, FileText } from 'lucide-react';
import { apiService } from '../services/api';
import { useErrorHandler } from '../hooks/useErrorHandler';
import Button from '../components/ui/Button';
import Input from '../components/ui/Input';
import LoadingSpinner from '../components/ui/LoadingSpinner';
import { Patient } from '../types';

interface SearchFilters {
  groupeSanguin: string;
  ageMin: string;
  ageMax: string;
  hasNFC: boolean;
}

const SearchPatient: React.FC = () => {
  const [searchTerm, setSearchTerm] = useState('');
  const [searchResults, setSearchResults] = useState<Patient[]>([]);
  const [loading, setLoading] = useState(false);
  const [showFilters, setShowFilters] = useState(false);
  const [recentSearches, setRecentSearches] = useState<string[]>([]);
  const [filters, setFilters] = useState<SearchFilters>({
    groupeSanguin: '',
    ageMin: '',
    ageMax: '',
    hasNFC: false
  });
  
  const navigate = useNavigate();
  const { handleApiError } = useErrorHandler();

  // Charger les recherches récentes depuis localStorage
  useEffect(() => {
    const saved = localStorage.getItem('recentSearches');
    if (saved) {
      try {
        setRecentSearches(JSON.parse(saved));
      } catch (e) {
        console.error('Erreur lors du chargement des recherches récentes:', e);
      }
    }
  }, []);

  // Sauvegarder les recherches récentes
  const saveRecentSearch = (term: string) => {
    const trimmedTerm = term.trim();
    if (!trimmedTerm) return;
    
    setRecentSearches(prev => {
      const newSearches = [trimmedTerm, ...prev.filter(s => s !== trimmedTerm)].slice(0, 5);
      localStorage.setItem('recentSearches', JSON.stringify(newSearches));
      return newSearches;
    });
  };

  const handleSearch = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!searchTerm.trim()) return;
    
    await performSearch(searchTerm);
    saveRecentSearch(searchTerm);
  };

  const handleQuickSearch = (term: string) => {
    setSearchTerm(term);
    performSearch(term);
  };

  const clearFilters = () => {
    setFilters({
      groupeSanguin: '',
      ageMin: '',
      ageMax: '',
      hasNFC: false
    });
  };

  const performSearch = async (term: string) => {
    try {
      setLoading(true);
      console.log('🔍 Recherche de patients pour:', term);
      
      const response = await apiService.searchPatients(term);
      
      if (response.success && response.data) {
        console.log('✅ Recherche réussie:', response.data.length, 'patients trouvés');
        setSearchResults(response.data);
      } else {
        console.log('❌ Erreur de recherche:', response.error);
        // Ne pas afficher d'erreur pour les recherches en temps réel
        // Seulement pour les recherches manuelles
        if (term.length > 2) {
          handleApiError(response.error || 'Erreur lors de la recherche');
        }
      }
    } catch (error) {
      console.error('❌ Exception lors de la recherche:', error);
      // Ne pas afficher d'erreur pour les recherches en temps réel
      // Seulement pour les recherches manuelles
      if (term.length > 2) {
        handleApiError(error, 'Erreur lors de la recherche');
      }
    } finally {
      setLoading(false);
    }
  };

  // Recherche en temps réel avec debounce - seulement si le terme fait plus de 2 caractères
  const debouncedSearch = useCallback(
    debounce((term: string) => {
      const trimmedTerm = term.trim();
      if (trimmedTerm.length >= 3) {
        console.log('🔍 Déclenchement recherche debounce pour:', trimmedTerm);
        performSearch(trimmedTerm);
      } else if (trimmedTerm.length === 0) {
        console.log('🔄 Réinitialisation des résultats');
        setSearchResults([]);
      }
      // Ne rien faire si le terme fait 1-2 caractères pour éviter trop de requêtes
    }, 500), // Augmenté à 500ms pour réduire les requêtes
    []
  );

  // Déclencher la recherche en temps réel seulement si le terme fait plus de 2 caractères
  useEffect(() => {
    const trimmedTerm = searchTerm.trim();
    if (trimmedTerm.length >= 3 || trimmedTerm.length === 0) {
      debouncedSearch(searchTerm);
    }
  }, [searchTerm, debouncedSearch]);

  const calculateAge = (dateNaissance: string) => {
    const birthDate = new Date(dateNaissance);
    const today = new Date();
    let age = today.getFullYear() - birthDate.getFullYear();
    const monthDiff = today.getMonth() - birthDate.getMonth();
    
    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
      age--;
    }
    
    return age;
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('fr-FR');
  };

  const formatPhone = (phone: string) => {
    const cleaned = phone.replace(/\D/g, '');
    if (cleaned.length === 10) {
      return cleaned.replace(/(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})/, '$1 $2 $3 $4 $5');
    }
    return phone;
  };

  const getGroupeSanguinColor = (groupe: string) => {
    const colors: { [key: string]: string } = {
      'A+': 'bg-red-100 text-red-800',
      'A-': 'bg-red-50 text-red-700',
      'B+': 'bg-blue-100 text-blue-800',
      'B-': 'bg-blue-50 text-blue-700',
      'AB+': 'bg-purple-100 text-purple-800',
      'AB-': 'bg-purple-50 text-purple-700',
      'O+': 'bg-green-100 text-green-800',
      'O-': 'bg-green-50 text-green-700'
    };
    return colors[groupe] || 'bg-gray-100 text-gray-800';
  };

  const isSearching = searchTerm.trim().length > 0;

  return (
    <div className="py-4 px-4 sm:px-6 lg:px-8">
      <div className="max-w-6xl mx-auto">
        <div className="flex flex-col sm:flex-row sm:justify-between sm:items-center mb-6 gap-4">
          <div>
            <h1 className="text-2xl font-bold text-gray-900 flex items-center">
              🔍 Rechercher un patient
              <span className="ml-2 text-blue-600 text-lg">⭐</span>
            </h1>
            <p className="text-gray-600 mt-1">Trouvez rapidement les informations de vos patients</p>
          </div>
          <Button
            variant="outline"
            size="sm"
            onClick={() => setShowFilters(!showFilters)}
            icon={<Filter size={16} />}
            className="w-full sm:w-auto"
          >
            {showFilters ? 'Masquer' : 'Afficher'} les filtres
          </Button>
        </div>
        
        <div className="bg-white rounded-lg shadow-sm border border-blue-200 bg-blue-50 mb-6">
          <div className="p-4 sm:p-6">
            <form onSubmit={handleSearch}>
              <div className="flex flex-col sm:flex-row gap-3">
                <div className="flex-grow">
                  <Input
                    type="text"
                    placeholder="Nom, prénom, numéro de dossier, téléphone..."
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    icon={<Search size={20} />}
                    className="w-full"
                  />
                </div>
                <Button 
                  type="submit" 
                  disabled={loading || !searchTerm.trim()}
                  className="w-full sm:w-auto bg-blue-600 hover:bg-blue-700"
                >
                  {loading ? 'Recherche...' : 'Rechercher'}
                </Button>
              </div>
            </form>

            {/* Recherches récentes */}
            {recentSearches.length > 0 && !searchTerm && (
              <div className="mt-4">
                <p className="text-sm text-gray-600 mb-2">Recherches récentes:</p>
                <div className="flex flex-wrap gap-2">
                  {recentSearches.map((term, index) => (
                    <button
                      key={index}
                      onClick={() => handleQuickSearch(term)}
                      className="px-3 py-1 text-sm bg-blue-100 hover:bg-blue-200 rounded-full transition-colors text-blue-700"
                    >
                      {term}
                    </button>
                  ))}
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Filtres avancés */}
        {showFilters && (
          <div className="bg-white rounded-lg shadow-sm border border-gray-200 mb-6">
            <div className="p-4 sm:p-6">
              <div className="flex flex-col sm:flex-row sm:justify-between sm:items-center mb-4 gap-2">
                <h3 className="text-lg font-semibold">Filtres avancés</h3>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={clearFilters}
                  icon={<X size={16} />}
                  className="w-full sm:w-auto"
                >
                  Effacer
                </Button>
              </div>
              
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Groupe sanguin
                  </label>
                  <select
                    value={filters.groupeSanguin}
                    onChange={(e) => setFilters(prev => ({ ...prev, groupeSanguin: e.target.value }))}
                    className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                  >
                    <option value="">Tous</option>
                    <option value="A+">A+</option>
                    <option value="A-">A-</option>
                    <option value="B+">B+</option>
                    <option value="B-">B-</option>
                    <option value="AB+">AB+</option>
                    <option value="AB-">AB-</option>
                    <option value="O+">O+</option>
                    <option value="O-">O-</option>
                  </select>
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Âge minimum
                  </label>
                  <Input
                    type="number"
                    placeholder="0"
                    value={filters.ageMin}
                    onChange={(e) => setFilters(prev => ({ ...prev, ageMin: e.target.value }))}
                    min="0"
                    max="150"
                  />
                </div>
                
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Âge maximum
                  </label>
                  <Input
                    type="number"
                    placeholder="100"
                    value={filters.ageMax}
                    onChange={(e) => setFilters(prev => ({ ...prev, ageMax: e.target.value }))}
                    min="0"
                    max="150"
                  />
                </div>
                
                <div className="flex items-end">
                  <label className="flex items-center">
                    <input
                      type="checkbox"
                      checked={filters.hasNFC}
                      onChange={(e) => setFilters(prev => ({ ...prev, hasNFC: e.target.checked }))}
                      className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
                    />
                    <span className="ml-2 text-sm text-gray-700">Avec carte NFC</span>
                  </label>
                </div>
              </div>
            </div>
          </div>
        )}
        
        {/* Résultats */}
        {isSearching && (
          <div className="bg-white rounded-lg shadow-sm border border-gray-200">
            <div className="px-4 py-3 border-b border-gray-200">
              <h2 className="text-lg font-semibold">
                Résultats ({searchResults.length})
              </h2>
            </div>
            
            {loading ? (
              <div className="p-6 text-center">
                <LoadingSpinner />
                <p className="text-gray-500 mt-2">Recherche en cours...</p>
              </div>
            ) : searchResults.length === 0 ? (
              <div className="p-6 text-center">
                <div className="text-gray-400 mb-2">🔍</div>
                <p className="text-gray-500">Aucun patient trouvé pour "{searchTerm}"</p>
                <p className="text-sm text-gray-400 mt-1">Essayez avec d'autres termes ou vérifiez l'orthographe</p>
              </div>
            ) : (
              <ul className="divide-y divide-gray-200">
                {searchResults.map(patient => (
                  <li key={patient.id} className="px-4 py-4 hover:bg-gray-50 transition-colors">
                    <button 
                      className="w-full text-left"
                      onClick={() => navigate(`/patient/${patient.id}`)}
                    >
                      <div className="flex items-start">
                        <div className="flex-shrink-0 h-12 w-12 bg-blue-100 rounded-full flex items-center justify-center">
                          <User className="h-6 w-6 text-blue-600" />
                        </div>
                        <div className="ml-4 flex-1 min-w-0">
                          <div className="flex flex-col">
                            <div className="flex items-start justify-between">
                              <div className="flex-1 min-w-0">
                                <div className="text-sm font-medium text-gray-900 truncate">
                                  {patient.prenom} {patient.nom}
                                </div>
                                <div className="text-sm text-gray-500 mt-1">
                                  <div className="flex items-center">
                                    <Calendar size={14} className="mr-1 flex-shrink-0" />
                                    {calculateAge(patient.dateNaissance)} ans ({formatDate(patient.dateNaissance)})
                                  </div>
                                </div>
                              </div>
                              <div className="ml-2">
                                <span className="inline-flex items-center px-2 py-1 text-xs font-medium rounded-full bg-blue-100 text-blue-800">
                                  Voir
                                </span>
                              </div>
                            </div>
                            
                            <div className="mt-2 text-sm text-gray-500">
                              <div className="grid grid-cols-1 sm:grid-cols-2 gap-1">
                                <div className="flex items-center">
                                  <FileText size={14} className="mr-1 flex-shrink-0" />
                                  <span className="truncate">Dossier {patient.numeroDossier}</span>
                                </div>
                                {patient.telephone && (
                                  <div className="flex items-center">
                                    <Phone size={14} className="mr-1 flex-shrink-0" />
                                    <a 
                                      href={`tel:${patient.telephone}`}
                                      className="hover:text-blue-600 transition-colors truncate"
                                      onClick={(e) => e.stopPropagation()}
                                    >
                                      {formatPhone(patient.telephone)}
                                    </a>
                                  </div>
                                )}
                                {patient.email && (
                                  <div className="flex items-center sm:col-span-2">
                                    <Mail size={14} className="mr-1 flex-shrink-0" />
                                    <a 
                                      href={`mailto:${patient.email}`}
                                      className="hover:text-blue-600 transition-colors truncate"
                                      onClick={(e) => e.stopPropagation()}
                                    >
                                      {patient.email}
                                    </a>
                                  </div>
                                )}
                                {patient.groupeSanguin && (
                                  <div className="sm:col-span-2">
                                    <span className={`inline-block px-2 py-1 text-xs rounded-full ${getGroupeSanguinColor(patient.groupeSanguin)}`}>
                                      {patient.groupeSanguin}
                                    </span>
                                  </div>
                                )}
                              </div>
                            </div>
                          </div>
                        </div>
                      </div>
                    </button>
                  </li>
                ))}
              </ul>
            )}
          </div>
        )}
      </div>
    </div>
  );
};

// Fonction utilitaire pour le debounce
function debounce<T extends (...args: any[]) => any>(
  func: T,
  wait: number
): (...args: Parameters<T>) => void {
  let timeout: number;
  return (...args: Parameters<T>) => {
    clearTimeout(timeout);
    timeout = setTimeout(() => func(...args), wait);
  };
}

export default SearchPatient;