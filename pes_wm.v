module pes_wm(clk, reset, door_close, start, filled, detergent_added, cycle_timeout, drained, spin_timeout, door_lock, motor_on, fill_value_on, drain_value_on, done, soap_wash, water_wash);

	input clk, reset, door_close, start, filled, detergent_added, cycle_timeout, drained, spin_timeout;
	output reg door_lock, motor_on, fill_value_on, drain_value_on, done, soap_wash, water_wash; 
	
	//defining the states
	parameter check_door = 3'b000;
	parameter fill_water = 3'b001;
	parameter add_detergent = 3'b010;
	parameter cycle = 3'b011;
	parameter drain_water = 3'b100;
	parameter spin = 3'b101;
        
        
	reg[2:0] current_state; 
	reg [2:0] next_state;
	
	always@(*)
	begin
	case(current_state)
		check_door:
			if(start==1 && door_close==1)
			begin
				next_state = fill_water;
				motor_on = 0;
				fill_value_on = 0;
				drain_value_on = 0;
				door_lock = 1;
				soap_wash = 0;
				water_wash = 0;
				done = 0;
			end
			else
			begin
				next_state = current_state;
				motor_on = 0;
				fill_value_on = 0;
				drain_value_on = 0;
				door_lock = 0;
				soap_wash = 0;
				water_wash = 0;
				done = 0;
			end
			
			fill_water:
			if (filled==1)
			begin
				if(soap_wash == 0)
				begin
					next_state = add_detergent;
					motor_on = 0;
					fill_value_on = 0;
					drain_value_on = 0;
					door_lock = 1;
					soap_wash = 0;
					water_wash = 0;
					done = 0;
				end
				else
				begin
					next_state = cycle;
					motor_on = 0;
					fill_value_on = 0;
					drain_value_on = 0;
					door_lock = 1;
					soap_wash = 1;
					water_wash = 1;
					done = 0;
				end
			end
			else
			begin
				next_state = current_state;
				motor_on = 0;
				fill_value_on = 1;
				drain_value_on = 0;
				door_lock = 1;
				done = 0;
                                soap_wash = 0;
                                water_wash = 0;
			end
			add_detergent:
			if(detergent_added==1)
			begin
				next_state = cycle;
				motor_on = 0;
				fill_value_on = 0;
				drain_value_on = 0;
				door_lock = 1;
				soap_wash = 1;
				done = 0;
                                water_wash = 0;
			end
			else
			begin
				next_state = current_state;
				motor_on = 0;
				fill_value_on = 0;
				drain_value_on = 0;
				door_lock = 1;
				soap_wash = 1;
				water_wash = 0;
				done = 0;
			end
			cycle:

			if(cycle_timeout == 1)
			begin
				if(water_wash == 0)
				begin
					next_state = drain_water;
					motor_on = 0;
					fill_value_on = 0;
					drain_value_on = 0;
					door_lock = 1;
					soap_wash = 1;
					water_wash = 0;
					done = 0;
				end
				else
				begin
					next_state = drain_water;
					motor_on = 0;
					fill_value_on = 0;
					drain_value_on = 0;
					door_lock = 1;
					soap_wash = 1;
					water_wash = 1;
					done = 0;
				end
			end
			else
			begin
				if(water_wash == 0)
				begin
					next_state = current_state;
					motor_on = 1;
					fill_value_on = 0;
					drain_value_on = 0;
					door_lock = 1;
					soap_wash = 1;
					water_wash = 0;
					done = 0;
				end
				else
				begin
					next_state = current_state;
					motor_on = 1;
					fill_value_on = 0;
					drain_value_on = 0;
					door_lock = 1;
					soap_wash = 1;
					water_wash = 1;
					done = 0;
				end
			end
			drain_water:
			 if(drained==1)
			 begin
				if(water_wash==0)
				begin
					next_state = fill_water;
					motor_on = 0;
					fill_value_on = 0;
					drain_value_on = 0;
					door_lock = 1;
					soap_wash = 1;
					water_wash = 0;
					done = 0;
				end
				else
				begin
				        next_state = spin;
					motor_on = 0;
					fill_value_on = 0;
					drain_value_on = 1;
					door_lock = 1;
					soap_wash = 1;
					water_wash = 1;
					done = 0;
				end
			end
			else
			begin
				next_state = current_state;
				motor_on = 0;
				fill_value_on = 0;
				drain_value_on = 0;
				door_lock = 1;
				soap_wash = 1;
				water_wash = 0;
				done = 0;
			end
			spin:
			if(spin_timeout==1)
			begin
				next_state = door_close;
				motor_on = 0;
				fill_value_on = 0;
				drain_value_on = 0;
				door_lock = 1;
				soap_wash = 1;
				water_wash = 1;
				done = 1;
			end
			else
			begin
				next_state = current_state;
				motor_on = 0;
				fill_value_on = 0;
				drain_value_on = 1;
				door_lock = 1;
				soap_wash = 1;
				water_wash = 1;
				done = 0;
			end
			default: begin
                                next_state = check_door;
                                motor_on = 0;
				fill_value_on = 0;
				drain_value_on = 0;
				door_lock = 0;
				soap_wash = 0;
				water_wash = 0;
				done = 0;
		        end
                                
				
			endcase
	end
	
	always@(posedge clk or posedge reset)
	begin
		if(reset)
		begin
			current_state<=3'b000;
		end
		else
		begin
			current_state<=next_state;
		end
	end
	
endmodule
