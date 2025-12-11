<template>
  <div class="contact-card" :data-contact-id="contact.id" @click="$emit('click', contact)">
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
  </div>
</template>

<script setup>
const props = defineProps({
  contact: {
    type: Object,
    required: true
  }
});

defineEmits(['click']);

const getInitials = (name) => {
  if (!name) return '?';
  const parts = name.split(' ');
  if (parts.length >= 2) {
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
  return name.substring(0, 2).toUpperCase();
};
</script>

<style scoped>
.contact-card {
  background: white;
  border-radius: 8px;
  padding: 12px;
  margin-bottom: 12px;
  cursor: pointer;
  transition: all 0.2s;
  border: 1px solid #e5e7eb;
  display: flex;
  align-items: center;
  gap: 12px;
}

.contact-card:hover {
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
  transform: translateY(-2px);
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
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.contact-email,
.contact-phone {
  font-size: 12px;
  color: #6b7280;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
</style>
