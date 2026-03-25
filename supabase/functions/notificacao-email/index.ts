import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

// SMTP ou Resend Configuration
const SMTP_API_KEY = Deno.env.get('SMTP_API_KEY') ?? '';

serve(async (req) => {
  try {
    const { record, type, franqueado_email, carro_codigo, campanha_nome, data_relatorio } = await req.json()
    
    let subject = "";
    let htmlContext = "";

    // 1. Lógica de roteamento
    switch(type) {
        case 'desligou':
            subject = `🔴 Painel desligado — ${carro_codigo}`;
            htmlContext = `<p>O painel do veículo ${carro_codigo} foi desligado.</p>`;
            break;
        case 'ligou':
            subject = `🟢 Painel ligado — ${carro_codigo}`;
            htmlContext = `<p>O painel do veículo ${carro_codigo} foi ligado.</p>`;
            break;
        case 'campanha_90':
            subject = `⚠️ Campanha quase concluída — ${campanha_nome}`;
            htmlContext = `<p>A campanha ${campanha_nome} atingiu 90% das horas contratadas.</p>`;
            break;
        case 'campanha_100':
            subject = `✅ Campanha concluída — ${campanha_nome}`;
            htmlContext = `<p>A campanha ${campanha_nome} atingiu 100% das horas contratadas.</p>`;
            break;
        case 'relatorio_diario':
            subject = `📊 Resumo do dia — ${data_relatorio}`;
            htmlContext = `<p>Seu relatório consolidado do dia ${data_relatorio} está pronto.</p>`;
            break;
        case 'sem_sinal':
            subject = `⚠️ Dispositivo sem sinal — ${carro_codigo}`;
            htmlContext = `<p>O dispositivo do carro ${carro_codigo} está sem sinal há mais de 1 hora.</p>`;
            break;
        default:
            throw new Error(`Tipo de notificação desconhecido: ${type}`);
    }

    // 2. Aqui ocorreria o POST para RESEND ou SendGrid
    console.log(`Disparando E-mail para: ${franqueado_email} | Assunto: ${subject}`);
    
    // const res = await fetch('https://api.resend.com/emails', {
    //   method: 'POST',
    //   headers: {
    //     'Authorization': `Bearer ${SMTP_API_KEY}`,
    //     'Content-Type': 'application/json'
    //   },
    //   body: JSON.stringify({
    //     from: 'noreply@ledtruck.com.br',
    //     to: franqueado_email,
    //     subject: subject,
    //     html: htmlContext
    //   })
    // });

    return new Response(JSON.stringify({ success: true, subject }), {
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
