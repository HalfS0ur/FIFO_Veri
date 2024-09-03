//Agente: Genera las secuencias de eventos para el driver

class agent #(parameter width = 16, parameter depth = 8);
    trans_fifo_mbx agnt_drv_mbx; //Mailbox del agente al driver
    comando_test_agent_mbx test_agent_mbx; //Mailbox del test al agente
    int num_transacciones; //Numero de transacciones para las funciones del agente
    int max_retardo;
    int ret_spec;
    tipo_trans tpo_spec;
    bit [width-1:0] dto_spec;
    instrucciones_agente instruccion; //Guarda la ultima instruccion leida
    trans_fifo #(.width(width)) transaccion;

    function new;
        num_transacciones = 2;
        max_retardo = 10;
    endfunction

    task run;
        $display("[%g]  El Agente fue inicializado",$time);
        forever begin
            if(test_agent_mbx.num() > 0) begin //Si el mbx no esta vacio
                $display("[%g]  Agente: se recibe instruccion",$time);
                test_agent_mbx.get(instruccion);
                case(instruccion) //Meter r&w
                    llenado_aleatorio: begin //Genera escrituras y lecturas de numeros aleatorios
                        for(int i = 0; i < num_transacciones; i++) begin
                            transaccion = new; //Construye una nueva transaccion
                            transaccion.max_retardo = max_retardo;
                            transaccion.randomize(); //Aleatoriza los datos
                            tpo_spec = escritura;
                            transaccion.tipo = tpo_spec; //PQ se usa tipo_spec?
                            transaccion.print("Agente: transaccion creada");
                            agnt_drv_mbx.put(transaccion);
                        end

                        for(int i = 0; i < num_transacciones; i++) begin
                            transaccion = new;
                            transaccion.randomize();
                            tipo_spec = lectura;
                            transaccion.tipo = tipo_spec;
                            transaccion.print("Agente: transaccion creada");
                            agnt_drv_mbx.put(transaccion);
                        end
                    end

                    trans_aleatoria: begin //Genera una transaccion aleatoria, duh
                        transaccion = new;
                        transaccion.max_retardo = max_retardo;
                        transaccion.randomize();
                        transaccion.print("Agente: transaccion creada");
                        agnt_drv_mbx.put(transaccion);
                    end

                    trans_especifica: begin //You guessed it
                        transaccion = new;
                        transaccion.tipo = tpo_spec; //How is x_spec determined?
                        transaccion.dato = dto_spec;
                        transaccion.retardo = ret_spec;
                        transaccion.print("Agente: transaccion creada");
                        agnt_drv_mbx.put(transaccion);
                    end

                    sec_trans_aleatorias: begin //Secuencia de transacciones aleatorias
                        for(int i = 0; i < num_transacciones; i++) begin
                            transaccion = new;
                            transaccion.max_retardo = max_retardo;
                            transaccion.randomize();
                            transaccion.print("Agente: transaccion creada");
                            agnt_drv_mbx.put(transaccion);
                        end
                    end
                endcase
            end
        end
    endtask
endclass