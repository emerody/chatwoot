<template>
  <div class="modal-overlay" @click.self="$emit('close')">
    <div class="modal-content pipedrive-style">
      <!-- Header Fixo -->
      <div class="modal-header">
        <div class="header-content">
          <div class="contact-header-info">
            <div class="contact-avatar-large">
              <img 
                v-if="fullContactData.thumbnail" 
                :src="fullContactData.thumbnail" 
                :alt="fullContactData.name"
              />
              <div v-else class="avatar-placeholder-large">
                {{ getInitials(fullContactData.name || contact.name) }}
              </div>
            </div>
            <div class="contact-title-section">
              <h2>{{ fullContactData.name || contact.name || 'Sem nome' }}</h2>
              <div class="contact-quick-info">
                <span v-if="fullContactData.email" class="quick-info-item">
                  <svg class="icon-small" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                  </svg>
                  {{ fullContactData.email }}
                </span>
                <span v-if="fullContactData.phone_number || contact.phone" class="quick-info-item">
                  <svg class="icon-small" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
                  </svg>
                  {{ fullContactData.phone_number || contact.phone }}
                </span>
              </div>
            </div>
          </div>
          <button class="close-btn" @click="$emit('close')">×</button>
        </div>
        
        <!-- Tabs Navigation -->
        <div class="tabs-container">
          <button
            v-for="tab in tabs"
            :key="tab.key"
            :class="['tab-button', { active: activeTab === tab.key }]"
            @click="activeTab = tab.key"
          >
            <span class="tab-icon">{{ tab.icon }}</span>
            <span class="tab-label">{{ tab.label }}</span>
            <span v-if="tab.count !== undefined && tab.count > 0" class="tab-count">{{ tab.count }}</span>
          </button>
        </div>
      </div>
      
      <!-- Body Content -->
      <div class="modal-body" v-if="contact">
        <div v-if="loading && activeTab === 'overview'" class="loading-state">
          <div class="spinner"></div>
          <p>Carregando detalhes...</p>
        </div>
        
        <!-- Tab: Overview -->
        <div v-else-if="activeTab === 'overview'" class="tab-content">
          <div class="overview-grid">
            <!-- Informações Básicas -->
            <div class="info-card">
              <h3 class="card-title">Informações Básicas</h3>
              <div class="info-list">
                <div v-if="fullContactData.name || contact.name" class="info-row">
                  <span class="info-label">Nome:</span>
                  <span class="info-value">{{ fullContactData.name || contact.name }}</span>
                </div>
                <div v-if="fullContactData.identifier" class="info-row">
                  <span class="info-label">ID:</span>
                  <span class="info-value">{{ fullContactData.identifier }}</span>
                </div>
                <div v-if="fullContactData.email" class="info-row">
                  <span class="info-label">Email:</span>
                  <a :href="`mailto:${fullContactData.email}`" class="info-link">{{ fullContactData.email }}</a>
                </div>
                <div v-if="fullContactData.phone_number || contact.phone" class="info-row">
                  <span class="info-label">Telefone:</span>
                  <a :href="`tel:${fullContactData.phone_number || contact.phone}`" class="info-link">{{ fullContactData.phone_number || contact.phone }}</a>
                </div>
                <div v-if="fullContactData.blocked" class="info-row">
                  <span class="info-label">Status:</span>
                  <span class="status-badge blocked">Bloqueado</span>
                </div>
              </div>
            </div>

            <!-- Informações Adicionais -->
            <div v-if="hasAdditionalInfo" class="info-card">
              <h3 class="card-title">Informações Adicionais</h3>
              <div class="info-list">
                <div v-if="additionalAttrs.city" class="info-row">
                  <span class="info-label">Cidade:</span>
                  <span class="info-value">{{ additionalAttrs.city }}</span>
                </div>
                <div v-if="additionalAttrs.country" class="info-row">
                  <span class="info-label">País:</span>
                  <span class="info-value">{{ additionalAttrs.country }}</span>
                </div>
                <div v-if="additionalAttrs.companyName" class="info-row">
                  <span class="info-label">Empresa:</span>
                  <span class="info-value">{{ additionalAttrs.companyName }}</span>
                </div>
                <div v-if="additionalAttrs.description" class="info-row full-width">
                  <span class="info-label">Descrição:</span>
                  <span class="info-value">{{ additionalAttrs.description }}</span>
                </div>
              </div>
            </div>

            <!-- Custom Attributes -->
            <div v-if="hasCustomAttributes" class="info-card">
              <h3 class="card-title">Atributos Customizados</h3>
              <div class="info-list">
                <div v-for="(value, key) in fullContactData.custom_attributes" :key="key" class="info-row">
                  <span class="info-label">{{ formatAttributeKey(key) }}:</span>
                  <span class="info-value">{{ formatCustomAttributeValue(value) }}</span>
                </div>
              </div>
            </div>

            <!-- Redes Sociais -->
            <div v-if="hasSocialProfiles" class="info-card">
              <h3 class="card-title">Redes Sociais</h3>
              <div class="social-grid">
                <a v-if="socialProfiles.linkedin" :href="socialProfiles.linkedin" target="_blank" rel="noopener noreferrer" class="social-card">
                  <svg class="social-icon" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z"/>
                  </svg>
                  <span>LinkedIn</span>
                </a>
                <a v-if="socialProfiles.facebook" :href="socialProfiles.facebook" target="_blank" rel="noopener noreferrer" class="social-card">
                  <svg class="social-icon" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/>
                  </svg>
                  <span>Facebook</span>
                </a>
                <a v-if="socialProfiles.instagram" :href="socialProfiles.instagram" target="_blank" rel="noopener noreferrer" class="social-card">
                  <svg class="social-icon" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zm0-2.163c-3.259 0-3.667.014-4.947.072-4.358.2-6.78 2.618-6.98 6.98-.059 1.281-.073 1.689-.073 4.948 0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98 1.281.058 1.689.072 4.948.072 3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98-1.281-.059-1.69-.073-4.949-.073zm0 5.838c-3.403 0-6.162 2.759-6.162 6.162s2.759 6.163 6.162 6.163 6.162-2.759 6.162-6.163c0-3.403-2.759-6.162-6.162-6.162zm0 10.162c-2.209 0-4-1.79-4-4 0-2.209 1.791-4 4-4s4 1.791 4 4c0 2.21-1.791 4-4 4zm6.406-11.845c-.796 0-1.441.645-1.441 1.44s.645 1.44 1.441 1.44c.795 0 1.439-.645 1.439-1.44s-.644-1.44-1.439-1.44z"/>
                  </svg>
                  <span>Instagram</span>
                </a>
                <a v-if="socialProfiles.twitter" :href="socialProfiles.twitter" target="_blank" rel="noopener noreferrer" class="social-card">
                  <svg class="social-icon" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M23.953 4.57a10 10 0 01-2.825.775 4.958 4.958 0 002.163-2.723c-.951.555-2.005.959-3.127 1.184a4.92 4.92 0 00-8.384 4.482C7.69 8.095 4.067 6.13 1.64 3.162a4.822 4.822 0 00-.666 2.475c0 1.71.87 3.213 2.188 4.096a4.904 4.904 0 01-2.228-.616v.06a4.923 4.923 0 003.946 4.827 4.996 4.996 0 01-2.212.085 4.936 4.936 0 004.604 3.417 9.867 9.867 0 01-6.102 2.105c-.39 0-.779-.023-1.17-.067a13.995 13.995 0 007.557 2.209c9.053 0 13.998-7.496 13.998-13.985 0-.21 0-.42-.015-.63A9.935 9.935 0 0024 4.59z"/>
                  </svg>
                  <span>Twitter</span>
                </a>
                <a v-if="socialProfiles.github" :href="socialProfiles.github" target="_blank" rel="noopener noreferrer" class="social-card">
                  <svg class="social-icon" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/>
                  </svg>
                  <span>GitHub</span>
                </a>
              </div>
            </div>

            <!-- Informações do Sistema -->
            <div class="info-card">
              <h3 class="card-title">Informações do Sistema</h3>
              <div class="info-list">
                <div v-if="fullContactData.created_at" class="info-row">
                  <span class="info-label">Criado em:</span>
                  <span class="info-value">{{ formatDate(fullContactData.created_at) }}</span>
                </div>
                <div v-if="fullContactData.last_activity_at" class="info-row">
                  <span class="info-label">Última atividade:</span>
                  <span class="info-value">{{ formatDate(fullContactData.last_activity_at) }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Tab: Conversas -->
        <div v-else-if="activeTab === 'conversations'" class="tab-content">
          <div v-if="loadingConversations" class="loading-state">
            <div class="spinner"></div>
            <p>Carregando conversas...</p>
          </div>
          <div v-else-if="conversations.length === 0" class="empty-state">
            <svg class="empty-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
            </svg>
            <p>Nenhuma conversa encontrada</p>
          </div>
          <div v-else class="conversations-list">
            <div
              v-for="conversation in conversations"
              :key="conversation.id"
              class="conversation-card"
            >
              <div class="conversation-header">
                <div class="conversation-meta">
                  <span class="conversation-status" :class="getStatusClass(conversation.status)">
                    {{ getStatusLabel(conversation.status) }}
                  </span>
                  <span class="conversation-time">{{ formatRelativeTime(conversation.last_activity_at || conversation.timestamp) }}</span>
                </div>
                <div v-if="getInboxName(conversation)" class="inbox-badge">
                  {{ getInboxName(conversation) }}
                </div>
              </div>
              <div v-if="getLastMessagePreview(conversation)" class="conversation-preview">
                <p class="preview-text">{{ getLastMessagePreview(conversation) }}</p>
              </div>
              <div class="conversation-footer">
                <span v-if="conversation.unread_count > 0" class="unread-badge">
                  {{ conversation.unread_count }} não lida{{ conversation.unread_count > 1 ? 's' : '' }}
                </span>
                <span v-if="conversation.meta?.assignee?.name" class="assignee-info">
                  Atribuído a: {{ conversation.meta.assignee.name }}
                </span>
              </div>
              <!-- Custom Attributes da Conversa -->
              <div v-if="conversation.custom_attributes && Object.keys(conversation.custom_attributes).length > 0" class="conversation-custom-attrs">
                <div class="custom-attrs-label">Atributos Customizados:</div>
                <div class="custom-attrs-list">
                  <span
                    v-for="(value, key) in conversation.custom_attributes"
                    :key="key"
                    class="custom-attr-badge"
                  >
                    {{ formatAttributeKey(key) }}: {{ formatCustomAttributeValue(value) }}
                  </span>
                </div>
              </div>
              <div class="conversation-actions">
                <button class="btn-view-conversation" @click="openConversation(conversation)">
                  <svg class="icon-small" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                  </svg>
                  Ver Conversa Completa
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- Tab: Notas -->
        <div v-else-if="activeTab === 'notes'" class="tab-content">
          <div class="notes-header">
            <button class="btn-primary" @click="showAddNote = true" v-if="!showAddNote">
              <svg class="icon-small" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
              </svg>
              Adicionar Nota
            </button>
          </div>

          <div v-if="showAddNote" class="add-note-form">
            <textarea
              v-model="newNoteContent"
              placeholder="Digite sua nota aqui..."
              class="note-textarea"
              rows="4"
            ></textarea>
            <div class="note-actions">
              <button class="btn-secondary" @click="cancelAddNote">Cancelar</button>
              <button class="btn-primary" @click="saveNote" :disabled="!newNoteContent.trim() || savingNote">
                {{ savingNote ? 'Salvando...' : 'Salvar' }}
              </button>
            </div>
          </div>

          <div v-if="loadingNotes" class="loading-state">
            <div class="spinner"></div>
            <p>Carregando notas...</p>
          </div>
          <div v-else-if="notes.length === 0 && !showAddNote" class="empty-state">
            <svg class="empty-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
            </svg>
            <p>Nenhuma nota encontrada</p>
          </div>
          <div v-else class="notes-timeline">
            <div
              v-for="note in notes"
              :key="note.id"
              class="note-item"
            >
              <div class="note-avatar">
                <div class="avatar-small">
                  {{ getInitials(note.user?.name || 'U') }}
                </div>
              </div>
              <div class="note-content">
                <div class="note-header">
                  <span class="note-author">{{ note.user?.name || 'Usuário' }}</span>
                  <span class="note-time">{{ formatRelativeTime(note.created_at) }}</span>
                </div>
                <div class="note-text">{{ note.content }}</div>
                <button v-if="canDeleteNote(note)" class="note-delete" @click="deleteNote(note.id)">
                  Excluir
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- Tab: Atividades -->
        <div v-else-if="activeTab === 'activities'" class="tab-content">
          <div class="activities-timeline">
            <!-- Conversas como atividades -->
            <div v-if="conversations.length > 0" class="activity-group">
              <h4 class="activity-group-title">Conversas ({{ conversations.length }})</h4>
              <div
                v-for="conversation in conversations"
                :key="`conv-${conversation.id}`"
                class="activity-item"
              >
                <div class="activity-icon conversation-icon">
                  <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
                  </svg>
                </div>
                <div class="activity-content">
                  <div class="activity-title">
                    Conversa {{ getStatusLabel(conversation.status) }}
                    <span class="activity-time">{{ formatRelativeTime(conversation.last_activity_at || conversation.timestamp) }}</span>
                  </div>
                  <div class="activity-description">
                    {{ getInboxName(conversation) || 'Canal desconhecido' }}
                  </div>
                </div>
              </div>
            </div>

            <!-- Notas como atividades -->
            <div v-if="notes.length > 0" class="activity-group">
              <h4 class="activity-group-title">Notas ({{ notes.length }})</h4>
              <div
                v-for="note in notes"
                :key="`note-${note.id}`"
                class="activity-item"
              >
                <div class="activity-icon note-icon">
                  <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                  </svg>
                </div>
                <div class="activity-content">
                  <div class="activity-title">
                    Nota adicionada por {{ note.user?.name || 'Usuário' }}
                    <span class="activity-time">{{ formatRelativeTime(note.created_at) }}</span>
                  </div>
                  <div class="activity-description">{{ note.content }}</div>
                </div>
              </div>
            </div>

            <div v-if="conversations.length === 0 && notes.length === 0" class="empty-state">
              <svg class="empty-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
              <p>Nenhuma atividade encontrada</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import ContactAPI from 'dashboard/api/contacts'
import ContactNotesAPI from 'dashboard/api/contactNotes'
import { dynamicTime } from 'shared/helpers/timeHelper'
import { frontendURL, conversationUrl } from 'dashboard/helper/URLHelper'
import MessageFormatter from 'shared/helpers/MessageFormatter'

export default {
  name: 'ContactModal',
  props: {
    contact: {
      type: Object,
      required: true
    }
  },
  data() {
    return {
      loading: false,
      loadingConversations: false,
      loadingNotes: false,
      savingNote: false,
      fullContactData: {},
      conversations: [],
      notes: [],
      activeTab: 'overview',
      showAddNote: false,
      newNoteContent: '',
      tabs: [
        { key: 'overview', label: 'Visão Geral', icon: '👤', count: 0 },
        { key: 'conversations', label: 'Conversas', icon: '💬', count: 0 },
        { key: 'notes', label: 'Notas', icon: '📝', count: 0 },
        { key: 'activities', label: 'Atividades', icon: '📊', count: 0 }
      ]
    }
  },
  computed: {
    ...mapGetters({
      currentAccount: 'getCurrentAccount',
      currentUser: 'getCurrentUser',
      inboxesList: 'inboxes/getInboxes'
    }),
    additionalAttrs() {
      return this.fullContactData.additional_attributes || {}
    },
    socialProfiles() {
      return this.additionalAttrs.socialProfiles || {}
    },
    hasAdditionalInfo() {
      return this.additionalAttrs.city || 
             this.additionalAttrs.country || 
             this.additionalAttrs.companyName || 
             this.additionalAttrs.description
    },
    hasSocialProfiles() {
      const social = this.socialProfiles
      return social.linkedin || social.facebook || social.instagram || 
             social.twitter || social.github
    },
    hasCustomAttributes() {
      return this.fullContactData.custom_attributes && 
             Object.keys(this.fullContactData.custom_attributes).length > 0
    }
  },
  watch: {
    contact: {
      immediate: true,
      handler(newContact) {
        // Inicializar com dados básicos imediatamente
        if (newContact) {
          this.fullContactData = { ...newContact }
        }
        
        if (newContact && newContact.id) {
          this.fetchFullContactData()
          this.fetchConversations()
          this.fetchNotes()
        }
      }
    },
    activeTab(newTab) {
      if (newTab === 'conversations' && this.conversations.length === 0) {
        this.fetchConversations()
      } else if (newTab === 'notes' && this.notes.length === 0) {
        this.fetchNotes()
      } else if (newTab === 'activities') {
        if (this.conversations.length === 0) this.fetchConversations()
        if (this.notes.length === 0) this.fetchNotes()
      }
    }
  },
  methods: {
    async fetchFullContactData() {
      if (!this.contact.id) return
      
      this.loading = true
      try {
        const accountId = this.currentAccount?.id
        if (!accountId) {
          console.error('Account ID não encontrado')
          this.fullContactData = { ...this.contact }
          return
        }

        const response = await this.$axios.get(
          `/api/v1/accounts/${accountId}/contacts/${this.contact.id}?include_contact_inboxes=false`
        )
        
        this.fullContactData = response.data.payload || this.contact
        console.log('ContactModal - fullContactData loaded:', this.fullContactData)
      } catch (error) {
        console.error('Erro ao buscar detalhes do contato:', error)
        this.fullContactData = { ...this.contact }
      } finally {
        this.loading = false
      }
    },
    async fetchConversations() {
      if (!this.contact.id) return
      
      this.loadingConversations = true
      try {
        const accountId = this.currentAccount?.id
        if (!accountId) {
          console.error('Account ID não encontrado')
          this.conversations = []
          return
        }
        
        const response = await this.$axios.get(
          `/api/v1/accounts/${accountId}/contacts/${this.contact.id}/conversations`
        )
        this.conversations = response.data.payload || []
        this.updateTabCount('conversations', this.conversations.length)
      } catch (error) {
        console.error('Erro ao buscar conversas:', error)
        this.conversations = []
      } finally {
        this.loadingConversations = false
      }
    },
    async fetchNotes() {
      if (!this.contact.id) return
      
      this.loadingNotes = true
      try {
        const response = await ContactNotesAPI.get(this.contact.id)
        this.notes = (response.data.payload || response.data || []).sort((a, b) => {
          const timeA = a.created_at || 0
          const timeB = b.created_at || 0
          return timeB - timeA
        })
        this.updateTabCount('notes', this.notes.length)
      } catch (error) {
        console.error('Erro ao buscar notas:', error)
        this.notes = []
      } finally {
        this.loadingNotes = false
      }
    },
    async saveNote() {
      if (!this.newNoteContent.trim() || !this.contact.id) return
      
      this.savingNote = true
      try {
        const accountId = this.currentAccount?.id
        if (!accountId) {
          this.$toast.error('Account ID não encontrado')
          return
        }

        // CORREÇÃO: Enviar no formato correto { note: { content: '...' } }
        const response = await this.$axios.post(
          `/api/v1/accounts/${accountId}/contacts/${this.contact.id}/notes`,
          { note: { content: this.newNoteContent.trim() } }
        )
        
        this.newNoteContent = ''
        this.showAddNote = false
        await this.fetchNotes()
        this.$toast.success('Nota salva com sucesso!')
      } catch (error) {
        console.error('Erro ao salvar nota:', error)
        const errorMessage = error.response?.data?.error || 'Erro ao salvar nota. Tente novamente.'
        this.$toast.error(errorMessage)
      } finally {
        this.savingNote = false
      }
    },
    async deleteNote(noteId) {
      if (!confirm('Tem certeza que deseja excluir esta nota?')) return
      
      try {
        await ContactNotesAPI.delete(this.contact.id, noteId)
        await this.fetchNotes()
      } catch (error) {
        console.error('Erro ao excluir nota:', error)
        alert('Erro ao excluir nota. Tente novamente.')
      }
    },
    cancelAddNote() {
      this.showAddNote = false
      this.newNoteContent = ''
    },
    updateTabCount(tabKey, count) {
      const tab = this.tabs.find(t => t.key === tabKey)
      if (tab) {
        this.$set(tab, 'count', count)
      }
    },
    openConversation(conversation) {
      const accountId = this.currentAccount?.id
      if (accountId) {
        // Usar uuid se disponível, senão usar id (display_id)
        const conversationId = conversation.uuid || conversation.id
        const path = frontendURL(
          conversationUrl({
            accountId: accountId,
            id: conversationId
          })
        )
        window.open(window.chatwootConfig.hostURL + path, '_blank')
      }
    },
    getInboxName(conversation) {
      // Buscar do store usando inbox_id
      const inboxId = conversation.inbox_id
      if (inboxId && this.inboxesList && this.inboxesList.length > 0) {
        const inbox = this.inboxesList.find(i => i.id === inboxId)
        if (inbox) return inbox.name
      }
      // Fallback: tentar do meta.channel se disponível
      if (conversation.meta?.channel) {
        return conversation.meta.channel
      }
      return null
    },
    getPlainText(message) {
      try {
        const formatter = new MessageFormatter(message)
        return formatter.plainText || ''
      } catch (e) {
        // Se falhar, retornar string vazia ou o próprio conteúdo
        return typeof message === 'string' ? message : ''
      }
    },
    getLastMessagePreview(conversation) {
      // Usar last_non_activity_message se disponível (formato preferido)
      if (conversation.last_non_activity_message) {
        const message = conversation.last_non_activity_message
        const content = message.content || ''
        if (content) {
          try {
            const plainText = this.getPlainText(content)
            return plainText.length > 100 ? plainText.substring(0, 100) + '...' : plainText
          } catch (e) {
            // Se getPlainText falhar, usar conteúdo direto
            const text = typeof content === 'string' ? content : JSON.stringify(content)
            return text.length > 100 ? text.substring(0, 100) + '...' : text
          }
        }
      }
      // Fallback para messages array
      if (conversation.messages && conversation.messages.length > 0) {
        const lastMessage = conversation.messages[conversation.messages.length - 1]
        const content = lastMessage.content || ''
        if (content) {
          try {
            const plainText = this.getPlainText(content)
            return plainText.length > 100 ? plainText.substring(0, 100) + '...' : plainText
          } catch (e) {
            const text = typeof content === 'string' ? content : JSON.stringify(content)
            return text.length > 100 ? text.substring(0, 100) + '...' : text
          }
        }
      }
      return null
    },
    getStatusClass(status) {
      const statusMap = {
        'open': 'status-open',
        'resolved': 'status-resolved',
        'pending': 'status-pending'
      }
      return statusMap[status] || 'status-default'
    },
    getStatusLabel(status) {
      const statusMap = {
        'open': 'Aberta',
        'resolved': 'Resolvida',
        'pending': 'Pendente'
      }
      return statusMap[status] || status
    },
    formatRelativeTime(timestamp) {
      if (!timestamp) return '-'
      try {
        const unixTime = typeof timestamp === 'number' ? timestamp : parseInt(timestamp)
        return dynamicTime(unixTime)
      } catch (error) {
        return '-'
      }
    },
    canDeleteNote(note) {
      return note.user?.id === this.currentUser?.id
    },
    getInitials(name) {
      if (!name || typeof name !== 'string') return '?'
      const parts = name.trim().split(' ').filter(p => p.length > 0)
      if (parts.length >= 2) {
        return (parts[0][0] + parts[1][0]).toUpperCase()
      }
      if (parts.length === 1 && parts[0].length >= 2) {
        return parts[0].substring(0, 2).toUpperCase()
      }
      return name.substring(0, 2).toUpperCase() || '?'
    },
    formatDate(timestamp) {
      if (!timestamp) return '-'
      try {
        const date = new Date(timestamp * 1000)
        if (isNaN(date.getTime())) {
          const dateISO = new Date(timestamp)
          if (isNaN(dateISO.getTime())) return '-'
          return dateISO.toLocaleDateString('pt-BR', {
            day: '2-digit',
            month: '2-digit',
            year: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
          })
        }
        return date.toLocaleDateString('pt-BR', {
          day: '2-digit',
          month: '2-digit',
          year: 'numeric',
          hour: '2-digit',
          minute: '2-digit'
        })
      } catch (error) {
        return '-'
      }
    },
    formatAttributeKey(key) {
      return key.split('_').map(word => 
        word.charAt(0).toUpperCase() + word.slice(1)
      ).join(' ')
    },
    formatCustomAttributeValue(value) {
      if (value === null || value === undefined) return '-'
      if (typeof value === 'boolean') return value ? 'Sim' : 'Não'
      if (typeof value === 'object') return JSON.stringify(value)
      return String(value)
    }
  }
}
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
  padding: 20px;
}

.modal-content {
  background: white;
  border-radius: 12px;
  width: 100%;
  max-width: 1200px;
  max-height: 90vh;
  display: flex;
  flex-direction: column;
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
}

.modal-content.pipedrive-style {
  max-width: 1400px;
}

.modal-header {
  background: #fff;
  border-bottom: 1px solid #e5e7eb;
  border-radius: 12px 12px 0 0;
  padding: 0;
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 24px;
}

.contact-header-info {
  display: flex;
  align-items: center;
  gap: 16px;
  flex: 1;
}

.contact-avatar-large {
  width: 64px;
  height: 64px;
  border-radius: 50%;
  overflow: hidden;
  background: #e5e7eb;
  flex-shrink: 0;
  border: 3px solid #f3f4f6;
}

.contact-avatar-large img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.avatar-placeholder-large {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  font-weight: 600;
  font-size: 24px;
}

.contact-title-section h2 {
  margin: 0 0 8px 0;
  font-size: 24px;
  font-weight: 600;
  color: #1f2937;
}

.contact-quick-info {
  display: flex;
  gap: 16px;
  flex-wrap: wrap;
}

.quick-info-item {
  display: flex;
  align-items: center;
  gap: 6px;
  color: #6b7280;
  font-size: 14px;
}

.close-btn {
  background: none;
  border: none;
  font-size: 28px;
  color: #6b7280;
  cursor: pointer;
  padding: 0;
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 6px;
  transition: all 0.2s;
}

.close-btn:hover {
  background: #f3f4f6;
  color: #1f2937;
}

.tabs-container {
  display: flex;
  border-bottom: 2px solid #e5e7eb;
  padding: 0 24px;
  gap: 8px;
  overflow-x: auto;
}

.tab-button {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 16px;
  background: none;
  border: none;
  border-bottom: 2px solid transparent;
  cursor: pointer;
  color: #6b7280;
  font-size: 14px;
  font-weight: 500;
  transition: all 0.2s;
  white-space: nowrap;
  margin-bottom: -2px;
}

.tab-button:hover {
  color: #3b82f6;
  background: #f9fafb;
}

.tab-button.active {
  color: #3b82f6;
  border-bottom-color: #3b82f6;
}

.tab-icon {
  font-size: 16px;
}

.tab-count {
  background: #e5e7eb;
  color: #6b7280;
  padding: 2px 8px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 600;
}

.tab-button.active .tab-count {
  background: #3b82f6;
  color: white;
}

.modal-body {
  flex: 1;
  overflow-y: auto;
  padding: 24px;
}

.loading-state {
  text-align: center;
  padding: 60px 20px;
  color: #6b7280;
}

.loading-state p {
  margin-top: 16px;
  font-size: 14px;
}

.spinner {
  border: 3px solid #f3f4f6;
  border-top: 3px solid #3b82f6;
  border-radius: 50%;
  width: 40px;
  height: 40px;
  animation: spin 1s linear infinite;
  margin: 0 auto;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.tab-content {
  animation: fadeIn 0.3s ease-in;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

/* Overview Tab */
.overview-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 20px;
}

.info-card {
  background: #f9fafb;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  padding: 20px;
}

.card-title {
  font-size: 16px;
  font-weight: 600;
  color: #1f2937;
  margin: 0 0 16px 0;
  padding-bottom: 12px;
  border-bottom: 2px solid #e5e7eb;
}

.info-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.info-row {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 12px;
}

.info-row.full-width {
  flex-direction: column;
}

.info-label {
  font-size: 13px;
  color: #6b7280;
  font-weight: 500;
  min-width: 100px;
}

.info-value {
  font-size: 14px;
  color: #1f2937;
  text-align: right;
  flex: 1;
  word-break: break-word;
}

.info-link {
  color: #3b82f6;
  text-decoration: none;
  font-size: 14px;
}

.info-link:hover {
  text-decoration: underline;
}

.status-badge {
  padding: 4px 12px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 600;
}

.status-badge.blocked {
  background: #fee2e2;
  color: #dc2626;
}

.social-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
  gap: 12px;
}

.social-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  padding: 16px;
  background: white;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  text-decoration: none;
  color: #3b82f6;
  transition: all 0.2s;
}

.social-card:hover {
  border-color: #3b82f6;
  transform: translateY(-2px);
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
}

.social-icon {
  width: 24px;
  height: 24px;
}

/* Conversations Tab */
.conversations-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.conversation-card {
  background: white;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  padding: 16px;
  transition: all 0.2s;
}

.conversation-card:hover {
  border-color: #3b82f6;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
}

.conversation-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.conversation-meta {
  display: flex;
  align-items: center;
  gap: 12px;
}

.conversation-status {
  padding: 4px 12px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 600;
}

.status-open {
  background: #dbeafe;
  color: #1e40af;
}

.status-resolved {
  background: #d1fae5;
  color: #065f46;
}

.status-pending {
  background: #fef3c7;
  color: #92400e;
}

.conversation-time {
  color: #6b7280;
  font-size: 12px;
}

.inbox-badge {
  background: #f3f4f6;
  color: #6b7280;
  padding: 4px 10px;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 500;
}

.conversation-preview {
  margin-bottom: 12px;
}

.preview-text {
  color: #4b5563;
  font-size: 14px;
  line-height: 1.5;
  margin: 0;
}

.conversation-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 12px;
  color: #6b7280;
  margin-bottom: 12px;
}

.unread-badge {
  background: #3b82f6;
  color: white;
  padding: 2px 8px;
  border-radius: 10px;
  font-weight: 600;
}

.assignee-info {
  color: #6b7280;
}

.conversation-custom-attrs {
  margin-top: 12px;
  padding-top: 12px;
  border-top: 1px solid #e5e7eb;
}

.custom-attrs-label {
  font-size: 12px;
  font-weight: 600;
  color: #6b7280;
  margin-bottom: 8px;
}

.custom-attrs-list {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.custom-attr-badge {
  background: #f3f4f6;
  color: #4b5563;
  padding: 4px 10px;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 500;
}

.conversation-actions {
  margin-top: 12px;
  padding-top: 12px;
  border-top: 1px solid #e5e7eb;
}

.btn-view-conversation {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 16px;
  background: #3b82f6;
  color: white;
  border: none;
  border-radius: 6px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
  width: 100%;
  justify-content: center;
}

.btn-view-conversation:hover {
  background: #2563eb;
}

/* Notes Tab */
.notes-header {
  margin-bottom: 20px;
}

.btn-primary {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 10px 16px;
  background: #3b82f6;
  color: white;
  border: none;
  border-radius: 6px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-primary:hover:not(:disabled) {
  background: #2563eb;
}

.btn-primary:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-secondary {
  padding: 10px 16px;
  background: white;
  color: #6b7280;
  border: 1px solid #e5e7eb;
  border-radius: 6px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-secondary:hover {
  background: #f9fafb;
}

.add-note-form {
  background: #f9fafb;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  padding: 16px;
  margin-bottom: 20px;
}

.note-textarea {
  width: 100%;
  padding: 12px;
  border: 1px solid #e5e7eb;
  border-radius: 6px;
  font-size: 14px;
  font-family: inherit;
  resize: vertical;
  margin-bottom: 12px;
}

.note-textarea:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.note-actions {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
}

.notes-timeline {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.note-item {
  display: flex;
  gap: 12px;
}

.note-avatar {
  flex-shrink: 0;
}

.avatar-small {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 600;
  font-size: 14px;
}

.note-content {
  flex: 1;
  background: #f9fafb;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  padding: 12px;
}

.note-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.note-author {
  font-weight: 600;
  color: #1f2937;
  font-size: 14px;
}

.note-time {
  color: #6b7280;
  font-size: 12px;
}

.note-text {
  color: #4b5563;
  font-size: 14px;
  line-height: 1.6;
  white-space: pre-wrap;
}

.note-delete {
  margin-top: 8px;
  padding: 4px 8px;
  background: none;
  border: none;
  color: #dc2626;
  font-size: 12px;
  cursor: pointer;
  text-decoration: underline;
}

.note-delete:hover {
  color: #991b1b;
}

/* Activities Tab */
.activities-timeline {
  position: relative;
  padding-left: 24px;
}

.activities-timeline::before {
  content: '';
  position: absolute;
  left: 8px;
  top: 0;
  bottom: 0;
  width: 2px;
  background: #e5e7eb;
}

.activity-group {
  margin-bottom: 32px;
}

.activity-group-title {
  font-size: 16px;
  font-weight: 600;
  color: #1f2937;
  margin-bottom: 16px;
  padding-left: 16px;
}

.activity-item {
  display: flex;
  gap: 16px;
  margin-bottom: 20px;
  position: relative;
}

.activity-icon {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  position: relative;
  z-index: 1;
}

.activity-icon svg {
  width: 18px;
  height: 18px;
}

.conversation-icon {
  background: #dbeafe;
  color: #1e40af;
}

.note-icon {
  background: #fef3c7;
  color: #92400e;
}

.activity-content {
  flex: 1;
  background: #f9fafb;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  padding: 12px;
}

.activity-title {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 4px;
  font-weight: 600;
  color: #1f2937;
  font-size: 14px;
}

.activity-time {
  color: #6b7280;
  font-size: 12px;
  font-weight: normal;
}

.activity-description {
  color: #4b5563;
  font-size: 13px;
  line-height: 1.5;
}

/* Empty States */
.empty-state {
  text-align: center;
  padding: 60px 20px;
  color: #6b7280;
}

.empty-icon {
  width: 64px;
  height: 64px;
  margin: 0 auto 16px;
  color: #d1d5db;
}

.empty-state p {
  font-size: 16px;
  margin: 0;
}

.icon-small {
  width: 16px;
  height: 16px;
}

@media (max-width: 768px) {
  .modal-content {
    max-width: 100%;
    max-height: 100vh;
    border-radius: 0;
  }

  .overview-grid {
    grid-template-columns: 1fr;
  }

  .tabs-container {
    padding: 0 16px;
  }

  .tab-button {
    padding: 10px 12px;
    font-size: 13px;
  }

  .tab-icon {
    display: none;
  }

  .header-content {
    padding: 16px;
  }

  .modal-body {
    padding: 16px;
  }
}
</style>
