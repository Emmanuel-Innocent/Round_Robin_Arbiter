/*
Author      : Emmanuel Innocent
Project     : Round Robin Arbiter
Email       : sherlockhudep7@gmail.com
Department  : Electronic and Electrical Engineering
Institution : Obafemi Awolowo University, Ile-Ife
LICENCE     : GNU GPL

*/

/*                                 DESCRIPTION:
This is the design of a work-conserving Round Robin Arbiter, with four (4) request queues.
Since this is an FPGA based project, the time-quanta(or time slice) has been chosen
such that the human eye can observe the changes in the output lines(LED).
For this design 3 seconds was chosen. However, the time slice can easily
be adjusted by changing the value of the "THREE_SECS_FREQ" variable in the code.
The clock frequency should be considered while changing the variable.

A 50MHz clock was used for this project.
*/


module WC_round_robin_arbiter
#(parameter integer THREE_SECS_FREQ = 150000000)
(input clk, input reset, input [3:0] request_queue, output [3:0] grant_out);


//The state variables --- 3-bit states
localparam [2:0]
                IDLE = 0,
                queue_1_priority = 1,
                queue_2_priority = 2,
                queue_3_priority = 3,
                queue_4_priority = 4;

reg [2:0] current_state, next_state;
reg enable;
integer time_counter = 0;  //helps count 3 seconds --- the time quanta
wire queues_are_empty;


//State Memory
always @ (posedge clk) begin
    if (reset) begin
        current_state <= IDLE;
    end

    else if (enable == 1'b1)begin
        current_state <= next_state;
    end
    
end


//measure(or count) three (3) seconds
//the time quanta/slice is 3 seconds 
always @ (posedge clk) begin
    time_counter = time_counter + 1;
    if (time_counter == THREE_SECS_FREQ) begin
        enable = 1'b1;
        time_counter = 0;
    end
    else enable = 1'b0;
    
end

//This line always checks if queues are empty of requests. If there are no request in any queue,
//the arbiter returns to the IDLE state to conserve work 
assign queues_are_empty = ~|(request_queue);      

//Next State Logic
always @ (current_state, queues_are_empty) begin
    case (current_state)
        IDLE: if (queues_are_empty == 1'b1) begin
                   next_state = IDLE;
              end
              else next_state = queue_1_priority;
        queue_1_priority:
                        if (queues_are_empty == 1'b1) begin
                              next_state = IDLE;
                         end
                        else next_state = queue_2_priority;
        queue_2_priority:
                        if (queues_are_empty == 1'b1) begin
                            next_state = IDLE;
                        end
                        else next_state = queue_3_priority;
        queue_3_priority:
                        if (queues_are_empty == 1'b1) begin
                            next_state = IDLE;
                        end
                        else next_state = queue_4_priority;
        queue_4_priority:
                        if (queues_are_empty == 1'b1) begin
                            next_state = IDLE;
                        end
                        else next_state = queue_1_priority;

    endcase



    
end

//Output Logic
always @(current_state, request_queue) begin
    case (current_state)
    IDLE : grant_out = 4'b0000;
    queue_1_priority :
                      if (request_queue[0]) begin
                          grant_out = 4'b0001;        
                      end
                      else if (request_queue[1]) begin
                          grant_out = 4'b0010;        
                      end
                      else if (request_queue[2]) begin
                          grant_out = 4'b0100;        
                      end
                      else if (request_queue[3]) begin
                          grant_out = 4'b1000;        
                      end
                      else grant_out = 4'b0000;
    queue_2_priority:
                    grant_out = request_queue[1]?4'b0010:request_queue[2]?4'b0100:request_queue[3]?4'b1000:request_queue[0]?4'b0001:4'b0000;

    queue_3_priority:
                    grant_out = request_queue[2]?4'b0100:request_queue[3]?4'b1000:request_queue[0]?4'b0001:request_queue[1]?4'b0010:4'b0000;

    queue_4_priority:
                    grant_out = request_queue[3]?4'b1000:request_queue[0]?4'b0001:request_queue[1]?4'b0010:request_queue[2]?4'b0100:4'b0000;


    endcase
    
end


endmodule
