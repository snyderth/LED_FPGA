module WS2812B_Driver#(parameter NUM_LEDS=1)
											(input		logic		clk, res,
							 				 output		logic		q);

		typedef enum logic[2:0]{D0, D1, RES} statetype;

		statetype state, nextstate;
		logic d; //color data
		//statereg
		always_ff @(posedge clk, posedge res) begin
				if(res)	state = RES; //Reset into reset state (send RES sig)
				else state = nextstate; //update the state
		end

		//output logic
		always_ff @(posedge clk) begin
			case (state)
				D0: //LOW sig
					if(DDR_count < 45) q <= 0; //output LOW for 45
					else if(DDR_count < 125) q <= 1; //output HIGH for the rest of bit
					else begin
						DDR_count <= 0; //After 1 bit, reset the count
						D_count <= D_count + 1; //increment
					end
				D1: //HIGH sig
					if(DDR_count < 40) q <= 1; //output HIGH for 40
					else if(DDR_count < 125) q <= 0;
					else begin
						DDR_count <= 0;
						D_count <= D_count + 1;
					end
				RES: //RES sig
					if(DDR_count < 5000) q <= 0;
					else	DDR_count <= 0;
			endcase
		end


		//nextstate logic
		always_ff @(posedge clk) begin
			case (state)
				D0:
					if(D_count >= (NUM_LEDS*24) - 1) begin
					 	nextstate <= RES;
						D_count <= 0;
				 	end
					else if(d & ~(DDR_count < 125))	nextstate <= D1;
				D1:
					if(D_count >= (NUM_LEDS*24) - 1) begin
						nextstate <= RES;
						D_count <= 0;
					end
					else if(~d & ~(DDR_count < 125))	nextstate <= D0;
				RES:
					if(DDR_count >= 4999 & d) nextstate <= D1;
					else if(DDR_count >= 4999 & ~d) nextstate <= D0;
			endcase
		end


/*******COUNTERS********/
		logic [12:0] DDR_count, D_count;

		//DDR counter
		always_ff @(posedge clk, posedge res) begin
				if(res) DDR_count <= 0;
				else DDR_count <= DDR_count + 2;
		end



		//D_counter
		// always_ff @(posedge clk, posedge res) begin
		// 	if(res) D_count <= 0;
		// 	else D_count <= D_count + 1;
		// end
/*************************/





endmodule
