<template>
  <div style="padding: 16px; max-width: 480px">
    <h2>Security Quotation Request</h2>

    <!-- Customer -->
    <label>Customer:</label>
    <select v-model="customerId" @change="loadSites">
      <option value="">-- select --</option>
      <option v-for="c in customers" :key="c.customerId" :value="c.customerId">
        {{ c.customerName }}
      </option>
    </select>

    <!-- Site: 只有选了customer而且拉到了site才显示 -->
    <div v-if="sites.length" style="margin-top:8px">
      <label>Site:</label>
      <select v-model="siteId">
        <option v-for="s in sites" :key="s.siteId" :value="s.siteId">
          {{ s.siteName }}
        </option>
      </select>
    </div>

    <div style="margin-top:8px">
      <label>Title:</label>
      <input v-model="title" />
    </div>

    <div style="margin-top:8px">
      <label>Start:</label>
      <input v-model="start" type="datetime-local" />
    </div>
    <div style="margin-top:8px">
      <label>End:</label>
      <input v-model="end" type="datetime-local" />
    </div>

    <button style="margin-top:12px" @click="submitRequest">Submit Request</button>

    <h3 style="margin-top:16px">Request response</h3>
    <pre v-if="lastResponse">{{ JSON.stringify(lastResponse, null, 2) }}</pre>

    <h3>Quotation</h3>
    <pre v-if="quotation">{{ JSON.stringify(quotation, null, 2) }}</pre>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import api from '../api/client'

const customers = ref([])
const sites = ref([])

const customerId = ref('')
const siteId = ref('')
const title = ref('Test request')
const start = ref('')
const end = ref('')

const lastResponse = ref(null)
const quotation = ref(null)

// 进页面先拉客户
onMounted(async () => {
  const res = await api.get('/customers')
  customers.value = res.data
})

// 根据customer拉site
const loadSites = async () => {
  sites.value = []
  siteId.value = ''
  if (!customerId.value) return
  const res = await api.get(`/customers/${customerId.value}/sites`)
  sites.value = res.data
  if (sites.value.length > 0) {
    siteId.value = sites.value[0].siteId
  }
}

const submitRequest = async () => {
  if (!customerId.value) {
    alert('select customer')
    return
  }
  if (!siteId.value) {
    alert('select site')
    return
  }

  const startIso = start.value ? new Date(start.value).toISOString() : new Date().toISOString()
  const endIso = end.value ? new Date(end.value).toISOString() : new Date().toISOString()

  const body = {
    customerId: customerId.value,
    siteId: siteId.value,
    title: title.value,
    description: 'created from vue',
    startDatetime: startIso,
    endDatetime: endIso
  }

  const res = await api.post('/requests', body)
  lastResponse.value = res.data

  const reqId = res.data.requestId
  const q = await api.post('/quotation-options/generate', null, {
    params: { requestId: reqId }
  })
  quotation.value = q.data
}
</script>
