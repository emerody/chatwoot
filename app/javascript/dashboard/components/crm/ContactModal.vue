<template>
  <div class="modal-overlay" @click.self="$emit('close')">
    <div class="modal-content large">
      <div class="modal-header">
        <h3>Detalhes do Contato</h3>
        <button class="close-btn" @click="$emit('close')">×</button>
      </div>
      
      <div class="modal-body" v-if="contact">
        <div v-if="loading" class="loading-state">
          <div class="spinner"></div>
          <p>Carregando detalhes...</p>
        </div>
        
        <div v-else class="contact-details">
          <div class="contact-header">
            <div class="contact-avatar-large">
              <img 
                v-if="fullContactData.thumbnail" 
                :src="fullContactData.thumbnail" 
                :alt="fullContactData.name"
              />
              <div v-else class="avatar-placeholder-large">
                {{ getInitials(fullContactData.name) }}
              </div>
            </div>
            <div class="contact-basic-info">
              <h2>{{ fullContactData.name || 'Sem nome' }}</h2>
              <div v-if="fullContactData.identifier" class="contact-field">
                <svg class="icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H5a2 2 0 00-2 2v9a2 2 0 002 2h14a2 2 0 002-2V8a2 2 0 00-2-2h-5m-4 0V5a2 2 0 114 0v1m-4 0a2 2 0 104 0m-5 8a2 2 0 100-4 2 2 0 000 4zm0 0c1.306 0 2.417.835 2.83 2M9 14a3.001 3.001 0 00-2.83 2M15 11h3m-3 4h2" />
                </svg>
                <span>ID: {{ fullContactData.identifier }}</span>
              </div>
              <div v-if="fullContactData.email" class="contact-field">
                <svg class="icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                </svg>
                <a :href="`mailto:${fullContactData.email}`">{{ fullContactData.email }}</a>
              </div>
              <div v-if="fullContactData.phone_number || contact.phone" class="contact-field">
                <svg class="icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
                </svg>
                <a :href="`tel:${fullContactData.phone_number || contact.phone}`">{{ fullContactData.phone_number || contact.phone }}</a>
              </div>
              <div v-if="fullContactData.blocked" class="contact-badge blocked">
                <svg class="icon-small" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18.364 18.364A9 9 0 005.636 5.636m12.728 12.728A9 9 0 015.636 5.636m12.728 12.728L5.636 5.636" />
                </svg>
                Bloqueado
              </div>
            </div>
          </div>
          
          <!-- Informações Adicionais -->
          <div v-if="hasAdditionalInfo" class="info-section">
            <h4 class="section-title">Informações Adicionais</h4>
            <div class="info-grid">
              <div v-if="additionalAttrs.city" class="info-item">
                <span class="info-label">Cidade:</span>
                <span class="info-value">{{ additionalAttrs.city }}</span>
              </div>
              <div v-if="additionalAttrs.country" class="info-item">
                <span class="info-label">País:</span>
                <span class="info-value">{{ additionalAttrs.country }}</span>
              </div>
              <div v-if="additionalAttrs.companyName" class="info-item">
                <span class="info-label">Empresa:</span>
                <span class="info-value">{{ additionalAttrs.companyName }}</span>
              </div>
              <div v-if="additionalAttrs.description" class="info-item full-width">
                <span class="info-label">Descrição:</span>
                <span class="info-value">{{ additionalAttrs.description }}</span>
              </div>
            </div>
          </div>

          <!-- Redes Sociais -->
          <div v-if="hasSocialProfiles" class="info-section">
            <h4 class="section-title">Redes Sociais</h4>
            <div class="social-links">
              <a v-if="socialProfiles.linkedin" :href="socialProfiles.linkedin" target="_blank" rel="noopener noreferrer" class="social-link">
                <svg class="icon" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z"/>
                </svg>
                LinkedIn
              </a>
              <a v-if="socialProfiles.facebook" :href="socialProfiles.facebook" target="_blank" rel="noopener noreferrer" class="social-link">
                <svg class="icon" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/>
                </svg>
                Facebook
              </a>
              <a v-if="socialProfiles.instagram" :href="socialProfiles.instagram" target="_blank" rel="noopener noreferrer" class="social-link">
                <svg class="icon" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zm0-2.163c-3.259 0-3.667.014-4.947.072-4.358.2-6.78 2.618-6.98 6.98-.059 1.281-.073 1.689-.073 4.948 0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98 1.281.058 1.689.072 4.948.072 3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98-1.281-.059-1.69-.073-4.949-.073zm0 5.838c-3.403 0-6.162 2.759-6.162 6.162s2.759 6.163 6.162 6.163 6.162-2.759 6.162-6.163c0-3.403-2.759-6.162-6.162-6.162zm0 10.162c-2.209 0-4-1.79-4-4 0-2.209 1.791-4 4-4s4 1.791 4 4c0 2.21-1.791 4-4 4zm6.406-11.845c-.796 0-1.441.645-1.441 1.44s.645 1.44 1.441 1.44c.795 0 1.439-.645 1.439-1.44s-.644-1.44-1.439-1.44z"/>
                </svg>
                Instagram
              </a>
              <a v-if="socialProfiles.twitter" :href="socialProfiles.twitter" target="_blank" rel="noopener noreferrer" class="social-link">
                <svg class="icon" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M23.953 4.57a10 10 0 01-2.825.775 4.958 4.958 0 002.163-2.723c-.951.555-2.005.959-3.127 1.184a4.92 4.92 0 00-8.384 4.482C7.69 8.095 4.067 6.13 1.64 3.162a4.822 4.822 0 00-.666 2.475c0 1.71.87 3.213 2.188 4.096a4.904 4.904 0 01-2.228-.616v.06a4.923 4.923 0 003.946 4.827 4.996 4.996 0 01-2.212.085 4.936 4.936 0 004.604 3.417 9.867 9.867 0 01-6.102 2.105c-.39 0-.779-.023-1.17-.067a13.995 13.995 0 007.557 2.209c9.053 0 13.998-7.496 13.998-13.985 0-.21 0-.42-.015-.63A9.935 9.935 0 0024 4.59z"/>
                </svg>
                Twitter
              </a>
              <a v-if="socialProfiles.github" :href="socialProfiles.github" target="_blank" rel="noopener noreferrer" class="social-link">
                <svg class="icon" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/>
                </svg>
                GitHub
              </a>
            </div>
          </div>

          <!-- Atributos Customizados -->
          <div v-if="hasCustomAttributes" class="info-section">
            <h4 class="section-title">Atributos Customizados</h4>
            <div class="info-grid">
              <div v-for="(value, key) in fullContactData.custom_attributes" :key="key" class="info-item">
                <span class="info-label">{{ formatAttributeKey(key) }}:</span>
                <span class="info-value">{{ value }}</span>
              </div>
            </div>
          </div>

          <!-- Informações do Sistema -->
          <div class="info-section">
            <h4 class="section-title">Informações do Sistema</h4>
            <div class="info-grid">
              <div v-if="fullContactData.created_at" class="info-item">
                <span class="info-label">Criado em:</span>
                <span class="info-value">{{ formatDate(fullContactData.created_at) }}</span>
              </div>
              <div v-if="fullContactData.last_activity_at" class="info-item">
                <span class="info-label">Última atividade:</span>
                <span class="info-value">{{ formatDate(fullContactData.last_activity_at) }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'

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
      fullContactData: {}
    }
  },
  computed: {
    ...mapGetters({
      currentAccount: 'getCurrentAccount'
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
        if (newContact && newContact.id) {
          this.fetchFullContactData()
        } else {
          // Se não tiver ID, usa os dados básicos passados
          this.fullContactData = { ...newContact }
        }
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
      } catch (error) {
        console.error('Erro ao buscar detalhes do contato:', error)
        // Em caso de erro, usa os dados básicos
        this.fullContactData = { ...this.contact }
      } finally {
        this.loading = false
      }
    },
    getInitials(name) {
      if (!name) return '?'
      const parts = name.split(' ')
      if (parts.length >= 2) {
        return (parts[0][0] + parts[1][0]).toUpperCase()
      }
      return name.substring(0, 2).toUpperCase()
    },
    formatDate(timestamp) {
      if (!timestamp) return '-'
      // Se for timestamp em segundos, converte para milissegundos
      const date = new Date(timestamp * 1000)
      // Verifica se a data é válida
      if (isNaN(date.getTime())) {
        // Tenta como string ISO
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
    },
    formatAttributeKey(key) {
      return key.split('_').map(word => 
        word.charAt(0).toUpperCase() + word.slice(1)
      ).join(' ')
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
}

.modal-content {
  background: white;
  border-radius: 8px;
  width: 90%;
  max-width: 500px;
  max-height: 90vh;
  overflow: auto;
}

.modal-content.large {
  max-width: 800px;
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
}

.contact-header {
  display: flex;
  gap: 20px;
  margin-bottom: 30px;
}

.contact-avatar-large {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  overflow: hidden;
  background: #e5e7eb;
  flex-shrink: 0;
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
  background: #3b82f6;
  color: white;
  font-weight: 600;
  font-size: 32px;
}

.contact-basic-info h2 {
  margin: 0 0 12px 0;
  font-size: 24px;
  color: #1f2937;
}

.contact-field {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #6b7280;
  margin-bottom: 8px;
}

.contact-field a {
  color: #3b82f6;
  text-decoration: none;
}

.contact-field a:hover {
  text-decoration: underline;
}

.icon {
  width: 18px;
  height: 18px;
  flex-shrink: 0;
}

.icon-small {
  width: 14px;
  height: 14px;
  flex-shrink: 0;
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

.info-section {
  margin-top: 24px;
  padding-top: 24px;
  border-top: 1px solid #e5e7eb;
}

.section-title {
  font-size: 16px;
  font-weight: 600;
  color: #1f2937;
  margin-bottom: 16px;
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 16px;
}

.info-item {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.info-item.full-width {
  grid-column: 1 / -1;
}

.info-label {
  font-size: 12px;
  color: #6b7280;
  font-weight: 500;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.info-value {
  font-size: 14px;
  color: #1f2937;
  line-height: 1.5;
}

.social-links {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
}

.social-link {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 16px;
  background: #f3f4f6;
  border-radius: 8px;
  color: #3b82f6;
  text-decoration: none;
  font-size: 14px;
  font-weight: 500;
  transition: all 0.2s;
}

.social-link:hover {
  background: #e5e7eb;
  transform: translateY(-1px);
}

.social-link .icon {
  width: 20px;
  height: 20px;
}

.contact-badge {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 6px 12px;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 500;
  margin-top: 8px;
}

.contact-badge.blocked {
  background: #fee2e2;
  color: #dc2626;
}

@media (max-width: 640px) {
  .info-grid {
    grid-template-columns: 1fr;
  }
  
  .social-links {
    flex-direction: column;
  }
  
  .social-link {
    width: 100%;
  }
}
</style>
