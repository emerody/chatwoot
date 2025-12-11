<template>
  <div class="crm-pipeline-view">
    <div class="crm-header">
      <h1 class="crm-title">CRM Pipeline</h1>
    </div>
    
    <PipelineBoard />
  </div>
</template>

<script setup>
import PipelineBoard from 'dashboard/components/crm/PipelineBoard.vue';
</script>

<style scoped>
.crm-pipeline-view {
  height: 100%;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.crm-header {
  padding: 20px 24px;
  border-bottom: 1px solid #e5e7eb;
  background: white;
}

.crm-title {
  font-size: 24px;
  font-weight: 600;
  color: #1f2937;
  margin: 0;
}
</style>




