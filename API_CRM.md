# API CRM - Documentação

Esta documentação descreve as APIs disponíveis para gerenciar o módulo CRM integrado ao Chatwoot.

## Autenticação

Todas as requisições requerem autenticação via token de acesso do Chatwoot. Inclua o token no header:

```
Authorization: api_access_token_{seu_token}
```

## Base URL

```
/api/v1/accounts/{account_id}/crm
```

## Endpoints

### 1. Obter Pipeline Padrão

Retorna o pipeline padrão do CRM com todos os stages e contatos associados.

**GET** `/api/v1/accounts/{account_id}/crm/pipelines/default`

**Resposta:**
```json
{
  "pipeline": {
    "id": 1,
    "name": "Pipeline Padrão",
    "is_default": true,
    "account_id": 1
  },
  "stages": [
    {
      "id": 1,
      "name": "Novo",
      "position": 1,
      "pipeline_id": 1,
      "account_id": 1,
      "contacts": [
        {
          "id": 1,
          "name": "João Silva",
          "email": "joao@example.com",
          "phone": "+5511999999999",
          "avatar_url": "https://...",
          "identifier": "contact_1",
          "current_stage": 1
        }
      ]
    }
  ]
}
```

### 2. Mover Contato para Stage

Move um contato para um stage específico do CRM. Se o contato já estiver em outro stage, ele será movido automaticamente.

**POST** `/api/v1/accounts/{account_id}/crm/contacts/{contact_id}/move_to_stage`

**Parâmetros:**
- `contact_id` (path): ID do contato
- `stage_id` (body): ID do stage de destino

**Body:**
```json
{
  "stage_id": 2
}
```

**Resposta:**
```json
{
  "success": true,
  "contact": {
    "id": 1,
    "name": "João Silva",
    "email": "joao@example.com",
    "phone": "+5511999999999",
    "avatar_url": "https://...",
    "identifier": "contact_1",
    "current_stage": 2
  },
  "stage": {
    "id": 2,
    "name": "Em Contato"
  }
}
```

### 3. Obter Contatos em um Stage

Retorna todos os contatos que estão em um stage específico.

**GET** `/api/v1/accounts/{account_id}/crm/contacts/contacts_in_stage?stage_id={stage_id}`

**Parâmetros:**
- `stage_id` (query): ID do stage

**Resposta:**
```json
{
  "stage_id": 1,
  "contacts": [
    {
      "id": 1,
      "name": "João Silva",
      "email": "joao@example.com",
      "phone": "+5511999999999",
      "avatar_url": "https://...",
      "identifier": "contact_1",
      "current_stage": 1
    }
  ]
}
```

### 4. Atualizar Stage

Atualiza o nome de um stage.

**PUT** `/api/v1/accounts/{account_id}/crm/stages/{stage_id}`

**Body:**
```json
{
  "name": "Novo Nome do Stage"
}
```

**Resposta:**
```json
{
  "id": 1,
  "name": "Novo Nome do Stage",
  "position": 1,
  "pipeline_id": 1,
  "account_id": 1
}
```

### 5. Reordenar Stages

Reordena os stages do pipeline.

**POST** `/api/v1/accounts/{account_id}/crm/stages/reorder`

**Body:**
```json
{
  "stage_ids": [3, 1, 2, 4]
}
```

**Resposta:**
```json
{
  "success": true,
  "message": "Stages reordenados com sucesso"
}
```

### 6. Deletar Stage

Remove um stage do pipeline. **Atenção:** Contatos no stage serão removidos do CRM.

**DELETE** `/api/v1/accounts/{account_id}/crm/stages/{stage_id}`

**Resposta:**
```json
{
  "success": true,
  "message": "Stage removido com sucesso"
}
```

## Exemplos de Uso para Automações

### Exemplo 1: Mover contato para CRM via Webhook

```bash
curl -X POST "https://seu-chatwoot.com/api/v1/accounts/1/crm/contacts/123/move_to_stage" \
  -H "Authorization: api_access_token_seu_token" \
  -H "Content-Type: application/json" \
  -d '{
    "stage_id": 1
  }'
```

### Exemplo 2: Verificar stage atual de um contato

```bash
curl -X GET "https://seu-chatwoot.com/api/v1/accounts/1/crm/pipelines/default" \
  -H "Authorization: api_access_token_seu_token"
```

### Exemplo 3: Integração com Zapier/Make.com

1. Configure um webhook no Zapier/Make.com
2. Use o endpoint `move_to_stage` para mover contatos
3. Configure triggers baseados em eventos do Chatwoot (nova conversa, mensagem, etc.)

### Exemplo 4: Script Python

```python
import requests

def move_contact_to_crm(account_id, contact_id, stage_id, api_token):
    url = f"https://seu-chatwoot.com/api/v1/accounts/{account_id}/crm/contacts/{contact_id}/move_to_stage"
    headers = {
        "Authorization": f"api_access_token_{api_token}",
        "Content-Type": "application/json"
    }
    data = {"stage_id": stage_id}
    
    response = requests.post(url, headers=headers, json=data)
    return response.json()

# Uso
result = move_contact_to_crm(
    account_id=1,
    contact_id=123,
    stage_id=2,
    api_token="seu_token_aqui"
)
print(result)
```

## Códigos de Status HTTP

- `200 OK`: Requisição bem-sucedida
- `201 Created`: Recurso criado com sucesso
- `400 Bad Request`: Parâmetros inválidos
- `401 Unauthorized`: Token de autenticação inválido ou ausente
- `404 Not Found`: Recurso não encontrado
- `500 Internal Server Error`: Erro interno do servidor

## Notas Importantes

1. **Múltiplos Contatos**: Um contato pode estar em apenas um stage por vez. Ao mover para um novo stage, ele é automaticamente removido do stage anterior.

2. **Timestamp**: O campo `moved_at` é automaticamente atualizado quando um contato é movido para um stage.

3. **Pipeline Padrão**: Cada conta tem um pipeline padrão criado automaticamente. Não é possível criar múltiplos pipelines no momento.

4. **Stages Padrão**: O pipeline padrão é criado com os seguintes stages:
   - Novo
   - Em Contato
   - Qualificado
   - Fechado

5. **Automações**: Você pode usar essas APIs para criar automações que movem contatos automaticamente baseado em:
   - Eventos de conversa (resolvida, nova mensagem, etc.)
   - Tags aplicadas
   - Atributos customizados
   - Webhooks externos

## Suporte

Para dúvidas ou problemas, consulte a documentação do Chatwoot ou entre em contato com o suporte.



