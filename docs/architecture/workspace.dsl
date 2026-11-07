workspace "Marketplace B2B de Sobras Industriais" "C4 Nivel 2 da funcionalidade de negociacao com Escrow" {

    model {
        comprador = person "Empresa Compradora" "Busca sobras, envia propostas e realiza o pagamento."

        vendedor = person "Empresa Vendedora" "Publica sobras e analisa propostas."

        escrow = softwareSystem "Gateway de Escrow" "Mantem o pagamento em custodia e envia confirmacoes." {
            tags "Sistema Externo"
        }

        notificacoes = softwareSystem "Servico de Notificacoes" "Envia avisos para as empresas." {
            tags "Sistema Externo"
        }

        marketplace = softwareSystem "Marketplace B2B de Sobras Industriais" "Intermedeia a negociacao de sobras industriais." {

            web = container "Aplicacao Web" "Interface utilizada pelas empresas compradoras e vendedoras." "React"

            api = container "Marketplace API" "Executa as regras de propostas, ofertas e transacoes." "Node.js 20 / REST API"

            worker = container "Worker de Eventos" "Processa eventos e solicita notificacoes." "Node.js 20"

            db = container "Banco de Dados" "Armazena ofertas, propostas, transacoes e auditoria." "PostgreSQL 16" {
                tags "Database"
            }

            broker = container "Broker de Mensagens" "Transporta eventos de proposta e pagamento." "RabbitMQ" {
                tags "Queue"
            }
        }

        comprador -> web "Busca ofertas, envia propostas e acompanha transacoes" "HTTPS"

        vendedor -> web "Publica ofertas e aceita ou rejeita propostas" "HTTPS"

        web -> api "Executa operacoes do marketplace" "JSON / REST / HTTPS"

        api -> db "Le e grava ofertas, propostas e transacoes" "SQL / TCP"

        api -> escrow "Cria cobranca e consulta a transacao" "JSON / REST / HTTPS"

        escrow -> api "Confirma ou rejeita o pagamento" "Webhook / HTTPS"

        api -> broker "Publica eventos de dominio" "AMQP 0-9-1"

        broker -> worker "Entrega eventos de dominio" "AMQP 0-9-1"

        worker -> notificacoes "Solicita o envio de avisos" "JSON / REST / HTTPS"

        notificacoes -> comprador "Envia avisos sobre a transacao" "E-mail"

        notificacoes -> vendedor "Envia avisos sobre proposta e pagamento" "E-mail"
    }

    views {
        container marketplace "Containers" {
            include *
            autoLayout lr
        }

        styles {
            element "Person" {
                shape person
                background #08427b
                color #ffffff
            }

            element "Software System" {
                background #1168bd
                color #ffffff
            }

            element "Container" {
                background #438dd5
                color #ffffff
            }

            element "Database" {
                shape cylinder
            }

            element "Queue" {
                shape pipe
            }

            element "Sistema Externo" {
                background #999999
                color #ffffff
            }
        }
    }
}
