<template>
  <div class="modal-overlay" @click.self="$emit('close')">
    <div class="modal-content large">
      <div class="modal-header">
        <h3>Detalhes do Contato</h3>
        <button class="close-btn" @click="$emit('close')">×</button>
      </div>
      
      <div class="modal-body" v-if="contact">
        <!-- Aqui você pode reutilizar componentes do Chatwoot para exibir todas as informações do contato -->
        <!-- Por exemplo, o componente de detalhes de contato que já existe no Chatwoot -->
        
        <div class="contact-details">
          <div class="contact-header">
            <div class="contact-avatar-large">
              <img 
                v-if="contact.avatar_url" 
                :src="contact.avatar_url" 
                :alt="contact.name"
              />
              <div v-else class="avatar-placeholder-large">
                {{ getInitials(contact.name) }}
              </div>
            </div>
            <div class="contact-basic-info">
              <h2>{{ contact.name || 'Sem nome' }}</h2>
              <div v-if="contact.email" class="contact-field">
                <i class="icon-mail"></i>
                {{ contact.email }}
              </div>
              <div v-if="contact.phone" class="contact-field">
                <i class="icon-phone"></i>
                {{ contact.phone }}
              </div>
            </div>
          </div>
          
          <!-- Adicionar aqui outras informações do contato -->
          <!-- Conversas, histórico, notas, tags, etc. -->
          <!-- Você pode importar e reutilizar componentes existentes do Chatwoot -->
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ContactModal',
  props: {
    contact: {
      type: Object,
      required: true
    }
  },
  methods: {
    getInitials(name) {
      if (!name) return '?'
      const parts = name.split(' ')
      if (parts.length >= 2) {
        return (parts[0][0] + parts[1][0]).toUpperCase()
      }
      return name.substring(0, 2).toUpperCase()
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
</style>

