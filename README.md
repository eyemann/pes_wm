![image](https://github.com/eyemann/pes_wm/assets/142375203/e3e1617e-1bb1-4b31-bbfe-3f9da9cf118d)

## OBJECTIVE


We will be implementing ASIC design flow through the design of an automatic Washing Machine

In a specific automatic washing machine there are usually six states as given above such as, Check door, Fill water, Add detergent, Cycle, Drain water and Spin


<details>
<summary> INTRODUCTION</summary>


- The system should provide fully automatic mode, semi-automatic mode and manual mode. Modes should be selectable by a keypad.
- When the lid is open system should not work. If door is accidentally opened in between wash operation, then the system should stop working in minimum possible time (<10s)>
- The system should provide all basic features of a washing machine like washing, rinsing, spinning, drying, cold wash, hot wash etc.
- The system should provide easy options for upgradeability of new features. The hardware and the software should be compatible to both machines, which have fewer features, or more features. Removal of any feature should not affect the working of any other features or overall working of the system.
- The system should work on single phase AC from 190VAC to 250VAC. The system should protect itself from power supply voltage variations.
- In the event of power failure, the washing machine should automatically start its cycle from the point of interruptionwhen power is resumed.

![image](https://github.com/eyemann/pes_wm/assets/142375203/2d400579-ee8e-4e49-bfa2-6c63c0d07291)


</details>
<details>
<summary> RTL synthesis and GLS simulation: </summary>

### Tools required:
1) **iverilog** Icarus Verilog or iverilog is an implementation of the Verilog hardware description language.
2) **GTKwave** GTKWave is a fully featured GTK+ v1. 2 based wave viewer for Unix and Win32 which reads Ver Structural Verilog Compiler generated AET files as well as standard Verilog VCD/EVCD files and allows their viewing.

## systemverilog code for .v file

 ~~~
//`timescale 10ns / 1ps
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
 ~~~

## systemverilog code for tb.v file
~~~
module pes_wm_tb();
	reg clk, reset, door_close, start, filled, detergent_added, cycle_timeout, drained, spin_timeout;
	wire door_lock, motor_on, fill_value_on, drain_value_on, done, soap_wash, water_wash; 
	
	
iiitb_wm machine1(clk, reset, door_close, start, filled, detergent_added, cycle_timeout, drained, spin_timeout, door_lock, motor_on, fill_value_on, drain_value_on, done, soap_wash, water_wash);


	
	
	initial
		
	begin
	clk = 0;
		reset = 1;
		start = 0;
		door_close = 0;
		filled = 0;
		drained = 0;
		detergent_added = 0;
		cycle_timeout = 0;
		spin_timeout = 0;
		
		#5 reset=0;
		#5 start=1;door_close=1;
		#10 filled=1;
		#10 detergent_added=1;
		//filled=0;
		#10 cycle_timeout=1;
		//detergent_added=0;
		#10 drained=1;
		//cycle_timeout=0;
		#10 spin_timeout=1;
		//drained=0;
		
		/*
		
		#0 reset = 0;
		#2 start = 1;
		#4 door_close = 1;
		#3 filled = 1;
		#3 detergent_added = 1;
		#2 cycle_timeout = 1;
		#2 drained = 1; 
		#3 spin_timeout = 1;
		*/
	end
	
	always
	begin
		#5 clk = ~clk;
	end
	
	initial
	begin
		$monitor("Time=%d, Clock=%b, Reset=%b, start=%b, door_close=%b, filled=%b, detergent_added=%b, cycle_timeout=%b, drained=%b, spin_timeout=%b, door_lock=%b, motor_on=%b, fill_valve_on=%b, drain_valve_on=%b, soap_wash=%b, water_wash=%b, done=%b",$time, clk, reset, start, door_close, filled, detergent_added, cycle_timeout, drained, spin_timeout, door_lock, motor_on, fill_value_on, drain_value_on, soap_wash, water_wash, done);
	end
  initial 
  begin
    $dumpfile("pes_wm_tb.vcd");
    $dumpvars(0,pes_wm_tb);
  end
endmodule
~~~





