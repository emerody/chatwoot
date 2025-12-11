<template>
  <div class="modal-overlay" @click.self="$emit('close')">
    <div class="modal-content">
      <div class="modal-header">
        <h3>Adicionar Contato ao Stage</h3>
        <button class="close-btn" @click="$emit('close')">×</button>
      </div>

      <div class="modal-body">
        <div class="search-section">
          <input
            v-model="searchQuery"
            type="text"
            class="search-input"
            placeholder="Buscar contatos..."
            @input="handleSearch"
          />
        </div>

        <div class="contacts-list" v-if="!isLoading">
          <div
            v-for="contact in filteredContacts"
            :key="contact.id"
            class="contact-item"
            @click="selectContact(contact)"
          >
            <div class="contact-avatar">
              <img
                v-if="contact.avatar_url"
                :src="contact.avatar_url"
                :alt="contact.name"
              />
              <div v-else class="avatar-placeholder">
                {{ getInitials(contact.name) }}
              </div>
            </div>
            <div class="contact-info">
              <div class="contact-name">{{ contact.name || 'Sem nome' }}</div>
              <div v-if="contact.email" class="contact-email">{{ contact.email }}</div>
              <div v-if="contact.phone_number" class="contact-phone">{{ contact.phone_number }}</div>
            </div>
            <div v-if="isContactInCrm(contact.id)" class="crm-badge">
              No CRM
            </div>
          </div>
          <div v-if="filteredContacts.length === 0" class="empty-state">
            Nenhum contato encontrado
          </div>
        </div>

        <div v-else class="loading-state">
          Carregando contatos...
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { useRoute } from 'vue-router';
import { useMapGetter } from 'dashboard/composables/store';
/* global axios */

const props = defineProps({
  stageId: {
    type: Number,
    required: true
  },
  existingContactIds: {
    type: Array,
    default: () => []
  }
});

const emit = defineEmits(['close', 'contact-selected']);

const route = useRoute();
const currentAccount = useMapGetter('getCurrentAccount');

const searchQuery = ref('');
const contacts = ref([]);
const isLoading = ref(false);
const contactsInCrm = ref([]);

const filteredContacts = computed(() => {
  if (!searchQuery.value) {
    return contacts.value.slice(0, 50); // Limitar a 50 contatos inicialmente
  }
  const query = searchQuery.value.toLowerCase();
  return contacts.value.filter(contact => {
    const name = (contact.name || '').toLowerCase();
    const email = (contact.email || '').toLowerCase();
    const phone = (contact.phone_number || '').toLowerCase();
    return name.includes(query) || email.includes(query) || phone.includes(query);
  }).slice(0, 50);
});

const loadContacts = async () => {
  try {
    isLoading.value = true;
    const accountId = currentAccount.value?.id || route.params.accountId;
    
    // Carregar contatos
    const contactsResponse = await axios.get(
      `/api/v1/accounts/${accountId}/contacts`,
      { params: { page: 1, per_page: 100 } }
    );
    contacts.value = contactsResponse.data.payload || [];

    // Carregar contatos que já estão no CRM
    const crmResponse = await axios.get(
      `/api/v1/accounts/${accountId}/crm/pipelines/default`
    );
    const allCrmContacts = [];
    if (crmResponse.data.stages) {
      crmResponse.data.stages.forEach(stage => {
        if (stage.contacts) {
          stage.contacts.forEach(contact => {
            allCrmContacts.push(contact.id);
          });
        }
      });
    }
    contactsInCrm.value = allCrmContacts;
  } catch (error) {
    console.error('Erro ao carregar contatos:', error);
  } finally {
    isLoading.value = false;
  }
};

const handleSearch = () => {
  // A busca é feita via computed filteredContacts
};

const selectContact = async (contact) => {
  emit('contact-selected', contact);
  emit('close');
};

const isContactInCrm = (contactId) => {
  return contactsInCrm.value.includes(contactId);
};

const getInitials = (name) => {
  if (!name) return '?';
  const parts = name.split(' ');
  if (parts.length >= 2) {
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
  return name.substring(0, 2).toUpperCase();
};

onMounted(() => {
  loadContacts();
});
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-content {
  background: white;
  border-radius: 8px;
  width: 90%;
  max-width: 600px;
  max-height: 80vh;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  border-bottom: 1px solid #e5e7eb;
}

.modal-header h3 {
  margin: 0;
  font-size: 18px;
  font-weight: 600;
  color: #1f2937;
}

.close-btn {
  background: none;
  border: none;
  font-size: 24px;
  color: #6b7280;
  cursor: pointer;
  padding: 0;
  width: 30px;
  height: 30px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.close-btn:hover {
  color: #1f2937;
}

.modal-body {
  padding: 20px;
  overflow-y: auto;
  flex: 1;
}

.search-section {
  margin-bottom: 20px;
}

.search-input {
  width: 100%;
  padding: 10px 12px;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  font-size: 14px;
  transition: border-color 0.2s;
}

.search-input:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.contacts-list {
  max-height: 400px;
  overflow-y: auto;
}

.contact-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  border-radius: 8px;
  cursor: pointer;
  transition: background-color 0.2s;
  border: 1px solid transparent;
}

.contact-item:hover {
  background-color: #f9fafb;
  border-color: #e5e7eb;
}

.contact-avatar {
  flex-shrink: 0;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  overflow: hidden;
  background: #e5e7eb;
}

.contact-avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.avatar-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #3b82f6;
  color: white;
  font-weight: 600;
  font-size: 14px;
}

.contact-info {
  flex: 1;
  min-width: 0;
}

.contact-name {
  font-weight: 600;
  color: #1f2937;
  font-size: 14px;
  margin-bottom: 4px;
}

.contact-email,
.contact-phone {
  font-size: 12px;
  color: #6b7280;
}

.crm-badge {
  background: #dbeafe;
  color: #1e40af;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 11px;
  font-weight: 500;
}

.empty-state,
.loading-state {
  text-align: center;
  padding: 40px;
  color: #6b7280;
}
</style>

