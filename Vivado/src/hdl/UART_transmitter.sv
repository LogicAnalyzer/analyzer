`timescale 1ns / 1ps
module uart_tx 
  #(parameter CLKS_PER_BIT = 10_416)
  (
   input  logic     reset_n,
   input  logic     i_Clock,
   input  logic     i_Tx_DV,
   input  logic[7:0]i_Tx_Byte, 
   output logic     o_Tx_Active,
   output logic     o_Tx_Serial,
   output logic     o_Tx_Done
   );
   
   typedef enum {s_IDLE, s_TX_START_BIT, s_TX_DATA_BITS, s_TX_STOP_BIT, s_CLEANUP}tx_uart_state;
   
  logic [$clog2(CLKS_PER_BIT)-1:0]    r_Clock_Count;
  logic [2:0]    r_Bit_Index;
  logic [7:0]    r_Tx_Data;
  logic          r_Tx_Done;
  logic          r_Tx_Active;
  tx_uart_state    r_SM_Main_ns, r_SM_Main_cs;
  
  always_ff@(posedge i_Clock)begin
    if(!reset_n)
        r_SM_Main_cs <= s_IDLE;
    else
        r_SM_Main_cs <= r_SM_Main_ns;
  end
  
  always_comb
  begin
    case(r_SM_Main_cs)
    s_IDLE :
    begin
        if (i_Tx_DV == 1'b1)
          r_SM_Main_ns   = s_TX_START_BIT;
        else
          r_SM_Main_ns = s_IDLE;
    end
    s_TX_START_BIT :
    begin
        if (r_Clock_Count < CLKS_PER_BIT-1)
            r_SM_Main_ns     = s_TX_START_BIT;
        else
            r_SM_Main_ns     = s_TX_DATA_BITS;
    end
    s_TX_DATA_BITS :
    begin
        if (r_Clock_Count < CLKS_PER_BIT-1)
            r_SM_Main_ns     = s_TX_DATA_BITS;
        else
            if (r_Bit_Index < 7)
                r_SM_Main_ns   = s_TX_DATA_BITS;
            else
                r_SM_Main_ns   = s_TX_STOP_BIT;
    end
    s_TX_STOP_BIT :
    begin
        if (r_Clock_Count < CLKS_PER_BIT-1)
            r_SM_Main_ns = s_TX_STOP_BIT;
        else
            r_SM_Main_ns = s_CLEANUP;
    end
    s_CLEANUP :
    begin
        r_SM_Main_ns = s_IDLE;
    end
    default:
    begin
        r_SM_Main_ns = s_IDLE;
    end
    
    endcase

  end
  
  always @(posedge i_Clock)
  begin
    if(!reset_n)begin
        o_Tx_Serial   <= 1'b1;         // Drive Line High for Idle
        r_Tx_Done     <= 1'b0;
        r_Clock_Count <= 0;
        r_Bit_Index   <= 0;
        r_Tx_Active <= 1'b0;
        r_Tx_Data   <= 0;
    end else
    begin
       
      case (r_SM_Main_cs)
        s_IDLE :
          begin
            o_Tx_Serial   <= 1'b1;         // Drive Line High for Idle
            r_Tx_Done     <= 1'b0;
            r_Clock_Count <= 0;
            r_Bit_Index   <= 0;
             
            if (i_Tx_DV == 1'b1)
              begin
                r_Tx_Active <= 1'b1;
                r_Tx_Data   <= i_Tx_Byte;
              end
          end // case: s_IDLE
         
         
        // Send out Start Bit. Start bit = 0
        s_TX_START_BIT :
          begin
            o_Tx_Serial <= 1'b0;
             
            // Wait CLKS_PER_BIT-1 clock cycles for start bit to finish
            if (r_Clock_Count < CLKS_PER_BIT-1)
                r_Clock_Count <= r_Clock_Count + 1;
            else
                r_Clock_Count <= 0;
          end // case: s_TX_START_BIT
         
         
        // Wait CLKS_PER_BIT-1 clock cycles for data bits to finish         
        s_TX_DATA_BITS :
          begin
            o_Tx_Serial <= r_Tx_Data[r_Bit_Index];
             
            if (r_Clock_Count < CLKS_PER_BIT-1)
              begin
                r_Clock_Count <= r_Clock_Count + 1;
              end
            else
              begin
                r_Clock_Count <= 0;
                 
                // Check if we have sent out all bits
                if (r_Bit_Index < 7)
                    r_Bit_Index <= r_Bit_Index + 1;
                else
                    r_Bit_Index <= 0;
              end
          end // case: s_TX_DATA_BITS
         
         
        // Send out Stop bit.  Stop bit = 1
        s_TX_STOP_BIT :
          begin
            o_Tx_Serial <= 1'b1;
             
            // Wait CLKS_PER_BIT-1 clock cycles for Stop bit to finish
            if (r_Clock_Count < CLKS_PER_BIT-1)
              begin
                r_Clock_Count <= r_Clock_Count + 1;
              end
            else
              begin
                r_Tx_Done     <= 1'b1;
                r_Clock_Count <= 0;
                r_Tx_Active   <= 1'b0;
              end
          end // case: s_Tx_STOP_BIT
         
         
        // Stay here 1 clock
        s_CLEANUP :
          begin
            r_Tx_Done <= 1'b1;
          end
         
      endcase
    end
  end
  assign o_Tx_Active = r_Tx_Active;
  assign o_Tx_Done   = r_Tx_Done;
   
endmodule