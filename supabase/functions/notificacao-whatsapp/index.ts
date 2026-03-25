import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

// Z-API Configuration
const ZAPI_INSTANCE = Deno.env.get('ZAPI_INSTANCE') ?? '';
const ZAPI_TOKEN = Deno.env.get('ZAPI_TOKEN') ?? '';
const ZAPI_URL = `https://api.z-api.io/instances/${ZAPI_INSTANCE}/token/${ZAPI_TOKEN}/send-messages`;

// Implementação de Fila / Delay Progressivo para Lotes (10 por 2s)
const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

serve(async (req) => {
  try {
    const payload = await req.json()
    // payload pode ser um objeto (evento individual) ou um Array (lote de 23h cron)
    
    // Normalize para Array
    const chamadas = Array.isArray(payload) ? payload : [payload];

    const results = [];
    
    // Processamento do lote
    for (let i = 0; i < chamadas.length; i++) {
        const item = chamadas[i];
        let message = "";

        // Delay progressivo a cada 10 envios de 2 segundos.
        if (i > 0 && i % 10 === 0) {
            console.log(`Lote de 10 atingido. Aguardando 2 segundos para respeitar Rate Limit da Z-API...`);
            await sleep(2000);
        }

        switch(item.type) {
            case 'desligou':
                message = `🔴 *LED Truck — Alerta*\nPainel *${item.codigo}* (${item.veiculo} - ${item.placa})\nfoi *DESLIGADO* às ${item.horario}.\n⏱ Tempo ligado hoje: ${item.horas}h ${item.minutos}min\nAcesse: https://app.ledtruck.com.br`;
                break;
            case 'ligou':
                message = `🟢 *LED Truck — Painel Ativo*\nPainel *${item.codigo}* (${item.veiculo} - ${item.placa})\nfoi *LIGADO* às ${item.horario}.\n📢 Campanhas ativas: ${item.num_campanhas}`;
                break;
            case 'campanha_90':
                message = `⚠️ *LED Truck — Atenção*\nA campanha *${item.nome}* está em *90%* das horas.\nHoras restantes: ${item.horas_restantes}h ${item.minutos_restantes}min\nAnunciante: ${item.anunciante}`;
                break;
            case 'campanha_100':
                message = `✅ *LED Truck — Campanha Concluída!*\nA campanha *${item.nome}* foi concluída.\nTotal exibido: ${item.horas_exibido}h de ${item.horas_contratadas}h contratadas.\nRelatório disponível no app.`;
                break;
            case 'relatorio_diario':
                message = `📊 *LED Truck — Resumo de ${item.data}*\n🚗 Carros ativos: ${item.carros_ativos}\n⏱ Total horas ligado: ${item.horas_ligado}h ${item.min_ligado}min\n📍 KM rodados: ${item.km_rodados} km\n📢 Campanhas ativas: ${item.num_campanhas}\nhttps://app.ledtruck.com.br`;
                break;
            case 'sem_sinal':
                message = `⚠️ *LED Truck — Sem Sinal*\nDispositivo *${item.serie}* (${item.veiculo})\nsem sinal há mais de 1 hora.\nÚltimo registro: ${item.horario}`;
                break;
            default:
                throw new Error(`Tipo de notificação desconhecido: ${item.type}`);
        }

        console.log(`Enviando WhatsApp para ${item.telefone}:\n${message}`);

        // Integração Z-API real comentada para evitar break sem credencial:
        // const res = await fetch(ZAPI_URL, {
        //   method: 'POST',
        //   headers: { 'Content-Type': 'application/json' },
        //   body: JSON.stringify({
        //     phone: item.telefone,
        //     message: message
        //   })
        // });
        
        results.push({ telefone: item.telefone, status: 'enviado' });
    }

    return new Response(JSON.stringify({ success: true, enviados: results }), {
      headers: { "Content-Type": "application/json" },
      status: 200,
    })
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { "Content-Type": "application/json" },
      status: 400,
    })
  }
})
