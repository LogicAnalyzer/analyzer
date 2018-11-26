`timescale 1ns / 1ps
module uart_rx 
  #(parameter CLKS_PER_BIT = 10_416)
  (
   input  logic       reset_n,
   input  logic       i_Clock,
   input  logic       i_Rx_Serial,
   output logic       o_Rx_DV,
   output logic [7:0] o_Rx_Byte
   );
   
  typedef enum {s_IDLE, s_RX_START_BIT, s_RX_DATA_BITS, s_RX_STOP_BIT, s_CLEANUP}rx_uart_state;
   
  logic           r_Rx_Data_R;
  logic           r_Rx_Data;
   
  logic [$clog2(CLKS_PER_BIT)-1:0]    r_Clock_Count;
  logic [2:0]     r_Bit_Index; //8 bits total
  logic [7:0]     r_Rx_Byte;
  logic           r_Rx_DV;
  rx_uart_state     r_SM_Main_ns;
  rx_uart_state     r_SM_Main_cs;
   
  // Purpose: Double-register the incoming data.
  // This allows it to be used in the UART RX Clock Domain.
  // (It removes problems caused by metastability)
  always @(posedge i_Clock)
    begin
      if(!reset_n)begin
        r_Rx_Data_R <=0;
        r_Rx_Data <=0;
      end
      r_Rx_Data_R <= i_Rx_Serial;
      r_Rx_Data   <= r_Rx_Data_R;
    end
  always_ff @(posedge i_Clock)
    begin
        if(!reset_n)
            r_SM_Main_cs  <= s_IDLE;
        else
            r_SM_Main_cs  <= r_SM_Main_ns;
    end
  
  always_comb begin
    case (r_SM_Main_cs)
        s_IDLE :
        begin
        if (r_Rx_Data == 1'b0)          // Start bit detected
          r_SM_Main_ns = s_RX_START_BIT;
        else
          r_SM_Main_ns = s_IDLE;
        end
        s_RX_START_BIT :
        begin
          if (r_Clock_Count == (CLKS_PER_BIT-1)/2)
          begin
            if (r_Rx_Data == 1'b0)
                r_SM_Main_ns     = s_RX_DATA_BITS;
            else
              r_SM_Main_ns = s_IDLE;
          end
        else
            r_SM_Main_ns     = s_RX_START_BIT;
        end
        s_RX_DATA_BITS :
        begin
          if (r_Clock_Count < CLKS_PER_BIT-1)
              r_SM_Main_ns     = s_RX_DATA_BITS;
          else
            begin
              if (r_Bit_Index < 7)
                  r_SM_Main_ns   = s_RX_DATA_BITS;
              else
                  r_SM_Main_ns   = s_RX_STOP_BIT;
            end
        end // case: s_RX_DATA_BITS
        s_RX_STOP_BIT :
        begin
          if (r_Clock_Count < CLKS_PER_BIT-1)
              r_SM_Main_ns     = s_RX_STOP_BIT;
          else
              r_SM_Main_ns     = s_CLEANUP;
        end
        s_CLEANUP :
        begin
            r_SM_Main_ns = s_IDLE;
        end
        default :
        begin
            r_SM_Main_ns = s_IDLE;
        end
    endcase
  end
   
  // Purpose: Control RX state machine
  always @(posedge i_Clock)
    begin
        if(!reset_n)begin
            r_Rx_DV       <= 1'b0;
            r_Clock_Count <= 0;
            r_Bit_Index   <= 0;
        end else begin
           
          case (r_SM_Main_cs)
            s_IDLE :
              begin
                r_Rx_DV       <= 1'b0;
                r_Clock_Count <= 0;
                r_Bit_Index   <= 0;
              end
             
            // Check middle of start bit to make sure it's still low
            s_RX_START_BIT :
              begin
                if (r_Clock_Count == (CLKS_PER_BIT-1)/2)
                    r_Clock_Count <=0;
                else
                  begin
                    r_Clock_Count <= r_Clock_Count + 1;
                  end
              end // case: s_RX_START_BIT
             
             
            // Wait CLKS_PER_BIT-1 clock cycles to sample serial data
            s_RX_DATA_BITS :
              begin
                if (r_Clock_Count < CLKS_PER_BIT-1)
                  begin
                    r_Clock_Count <= r_Clock_Count + 1;
                  end
                else
                  begin
                    r_Clock_Count          <= 0;
                    r_Rx_Byte[r_Bit_Index] <= r_Rx_Data;
                     
                    // Check if we have received all bits
                    if (r_Bit_Index < 7)
                        r_Bit_Index <= r_Bit_Index + 1;
                    else
                        r_Bit_Index <= 0;
                  end
              end // case: s_RX_DATA_BITS
         
         
            // Receive Stop bit.  Stop bit = 1
            s_RX_STOP_BIT :
              begin
                // Wait CLKS_PER_BIT-1 clock cycles for Stop bit to finish
                if (r_Clock_Count < CLKS_PER_BIT-1)
                  begin
                    r_Clock_Count <= r_Clock_Count + 1;
                  end
                else
                  begin
                    r_Rx_DV       <= 1'b1;
                    r_Clock_Count <= 0;
                  end
              end // case: s_RX_STOP_BIT
            // Stay here 1 clock
            s_CLEANUP :
              begin
                r_Rx_DV   <= 1'b0;
              end         
          endcase
        end
    end
   
  assign o_Rx_DV   = r_Rx_DV;
  assign o_Rx_Byte = r_Rx_Byte;
   
endmodule // uart_rx