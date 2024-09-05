//Transacciones posibles en la FIFO
//--------------------------------//
typedef enum {lectura, escritura, reset, lectoescritura} tipo_trans; 

//Objeto para representar las transacciones que entran y salen de la FIFO
class trans_fifo #(parameter width = 16);
  rand int retardo; //Tiempo de retardo en ciclos de reloj aleatorizados
  rand bit[width-1:0] dato; //Dato de la transaccion aleatorizado
  int tiempo; //Tiempo en el que se ejecutó la transacción 
  rand tipo_trans tipo; //lectura, escritura, reset;
  int max_retardo; //Retardo maximo entre transacciones
 
  constraint const_retardo {retardo < max_retardo; retardo>0;} //Constraint para el retardo entre transacciones

  function new(int ret =0,bit[width-1:0] dto=0,int tmp = 0, tipo_trans tpo = lectura, int mx_rtrd = 10); //Constructor de la clase trans_fifo
    this.retardo = ret;
    this.dato = dto;
    this.tiempo = tmp;
    this.tipo = tpo;
    this.max_retardo = mx_rtrd;
  endfunction
  
  function clean; //Limpieza de la clase
    this.retardo = 0;
    this.dato = 0;
    this.tiempo = 0;
    this.tipo = lectura;
    
  endfunction
    
  function void print(string tag = "");
    $display("[%g] %s Tiempo=%g Tipo=%s Retardo=%g dato=0x%h",$time,tag,tiempo,this.tipo,this.retardo,this.dato);
  endfunction
endclass

//Interface para concectar el FIFO al testbench
interface fifo_if #(parameter width =16) (
  input clk
);
  logic rst;
  logic pndng;
  logic full;
  logic push;
  logic pop;
  logic [width-1:0] dato_in; 
  logic [width-1:0] dato_out;

  endinterface

//Objeto de transaccion que le voy a mandar al scoreboard
class trans_sb #(parameter width=16);
  bit [width-1:0] dato_enviado;
  int tiempo_push;
  int tiempo_pop;
  bit completado;
  bit overflow;
  bit underflow;
  bit reset;
  int latencia;
  
  function clean();
    this.dato_enviado = 0;
    this.tiempo_push = 0;
    this.tiempo_pop = 0;
    this.completado = 0;
    this.overflow = 0;
    this.underflow = 0;
    this.reset = 0;
    this.latencia = 0;
  endfunction

  task calc_latencia;
    this.latencia = this.tiempo_pop - this.tiempo_push;
  endtask
  
  function print (string tag);
    $display("[%g] %s dato=%h,t_push=%g,t_pop=%g,cmplt=%g,ovrflw=%g,undrflw=%g,rst=%g,ltncy=%g", 
             $time,
             tag, 
             this.dato_enviado, 
             this.tiempo_push,
             this.tiempo_pop,
             this.completado,
             this.overflow,
             this.underflow,
             this.reset,
             this.latencia);
  endfunction
endclass

//Estructura para generar comandos hacia el scoreboard
typedef enum {retardo_promedio,reporte} solicitud_sb;

//Estructura para generar comandos hacia el agente
typedef enum {llenado_aleatorio,trans_aleatoria,trans_especifica,sec_trans_aleatorias,sec_trans_especificas} instrucciones_agente;

//Mailboxes para comunicar las interfaces
typedef mailbox #(trans_fifo) trans_fifo_mbx;

typedef mailbox #(trans_sb) trans_sb_mbx;

typedef mailbox #(solicitud_sb) comando_test_sb_mbx;

typedef mailbox #(instrucciones_agente) comando_test_agent_mbx;
