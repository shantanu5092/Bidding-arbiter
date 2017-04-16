module arb(bmif.mstrR mr0, bmif.mstrR mr1, bmif.mstrR mr2, bmif.mstrR mr3, svif.slvR sv0, svif.slvR sv1, svif.slvR sv2, svif.slvR sv3, input int rst_balance, rst_clock, max_balance);

  logic [3:0] mr0_req, mr1_req, mr2_req, mr3_req;
  logic [1:0]flagsv, flagsv_ff;

  int rst_count;
  int req0_timeout, req1_timeout, req2_timeout, req3_timeout;
  int req0_timeout_reg, req1_timeout_reg, req2_timeout_reg, req3_timeout_reg;
  int mr0_balance, mr1_balance, mr2_balance, mr3_balance;
  int mr0_rst_balance_reg, mr1_rst_balance_reg, mr2_rst_balance_reg, mr3_rst_balance_reg;
  int mr0_prior, mr1_prior, mr2_prior, mr3_prior;
  int mr0_prior_reg, mr1_prior_reg, mr2_prior_reg, mr3_prior_reg;

  always@(posedge (mr0.clk) or posedge (mr0.rst)) begin
	if (mr0.rst) begin
		//-----------------Master0-----------------------------
		mr0_balance		<= 900;
		mr0_prior		<= 0;
		////---------------Master1-----------------------------
		mr1_balance		<= 900;
		mr1_prior		<= 0;
		////---------------Master2-----------------------------
		mr2_balance		<= 900; 
		mr2_prior		<= 0;
		////---------------Master3-----------------------------
		mr3_balance		<= 900;
		mr3_prior		<= 0;
		
		rst_count		<= 0;
	end
	else begin
		if (rst_count == rst_clock) begin
			rst_count <= #1 0;
			if (mr0_balance + rst_balance >= max_balance) mr0_balance <= max_balance;
			else mr0_balance <= mr0_balance + rst_balance;
			if (mr1_balance + rst_balance >= max_balance) mr1_balance <= max_balance;
			else mr1_balance <= mr1_balance + rst_balance;
			if (mr2_balance + rst_balance >= max_balance) mr2_balance <= max_balance;
			else mr2_balance <= mr2_balance + rst_balance;
			if (mr3_balance + rst_balance >= max_balance) mr3_balance <= max_balance;
			else mr3_balance <= mr3_balance + rst_balance;
		end
		else begin
			rst_count <= #1 rst_count + 1;
			if(mr0.grant)
				if(mr0_balance <= 1)
					mr0_balance <= 1;
			  	else
		   			mr0_balance <= mr0_balance - mr0.req;
		   	else if(mr1.grant)
		   		mr1_balance <= mr1_balance - mr1.req;
		   	else if(mr2.grant)
		   		mr2_balance <= mr2_balance - mr2.req;
		   	else if(mr3.grant)
		   		mr3_balance <= mr3_balance - mr3.req;
		   	else begin
				mr0_balance <= mr0_balance;
		 		mr1_balance <= mr1_balance;
				mr2_balance <= mr2_balance;
				mr3_balance <= mr3_balance;
		   	end
		end
		//-----------------Master0-----------------------------
		if(mr0.grant)begin
			mr0_prior <=  0; 
			mr1_prior <=  mr1_prior + 1; 
			mr2_prior <=  mr2_prior + 1; 
			mr3_prior <=  mr3_prior + 1;
		end
		////---------------Master1-----------------------------
		if(mr1.grant)begin
			mr0_prior <=  mr0_prior + 1; 
			mr1_prior <=  0; 
			mr2_prior <=  mr2_prior + 1; 
			mr3_prior <=  mr3_prior + 1;
		end
		////---------------Master2-----------------------------
		if(mr2.grant)begin
			mr0_prior <=  mr0_prior + 1; 
			mr1_prior <=  mr1_prior + 1; 
			mr2_prior <=  0; 
			mr3_prior <=  mr3_prior + 1;
		end
		////---------------Master3-----------------------------
		if(mr3.grant)begin
			mr0_prior <=  mr0_prior + 1; 
			mr1_prior <=  mr1_prior + 1; 
			mr2_prior <=  mr2_prior + 1; 
			mr3_prior <=  0;
		end
	end
  end

  always@(*) begin
//-----------------------------------------------------------------------Req Var------------------------------------------------------------------
	if(mr0_balance == 1) mr0_req = 1;
	else mr0_req = mr0.req;
	if(mr1_balance == 1) mr1_req = 1;
	else mr1_req = mr1.req;
	if(mr2_balance == 1) mr2_req = 1;
	else mr2_req = mr2.req;
	if(mr3_balance == 1) mr3_req = 1;
	else mr3_req = mr3.req;


//-----------------------------------------------------------------------Arbiter Logic---------------------------------------------------------------------------------

		if ((mr0_req > mr1_req) && (mr0_req > mr2_req) && (mr0_req > mr3_req)) begin
			mr0.grant = 1; mr1.grant = 0; mr2.grant = 0; mr3.grant = 0;
		end
		else if ((mr1_req > mr0_req) && (mr1_req > mr2_req) && (mr1_req > mr3_req)) begin
			mr0.grant = 0; mr1.grant = 1; mr2.grant = 0; mr3.grant = 0;
		end
		else if ((mr2_req > mr1_req) && (mr2_req > mr0_req) && (mr2_req > mr3_req)) begin
			mr0.grant = 0; mr1.grant = 0; mr2.grant = 1; mr3.grant = 0;
		end
		else if ((mr3_req > mr1_req) && (mr3_req > mr2_req) && (mr3_req > mr0_req)) begin
			mr0.grant = 0; mr1.grant = 0; mr2.grant = 0; mr3.grant = 1;
		end
		else if ((mr1_req == mr2_req) && (mr1_req == mr0_req) && (mr1_req > mr3_req)) begin
			if ((mr0_prior > mr1_prior) && (mr0_prior > mr2_prior)) begin
				mr0.grant = 1; mr1.grant = 0; mr2.grant = 0; mr3.grant = 0;
			end
			else if ((mr1_prior > mr0_prior) && (mr1_prior > mr2_prior)) begin 
				mr0.grant = 0; mr1.grant = 1; mr2.grant = 0; mr3.grant = 0;
			end
			else if ((mr2_prior > mr0_prior) && (mr2_prior > mr1_prior)) begin
				mr0.grant = 0; mr1.grant = 0; mr2.grant = 1; mr3.grant = 0;
			end
		end
		else if ((mr0_req == mr2_req) && (mr0_req > mr1_req) && (mr0_req > mr3_req)) begin
			if (mr0_prior > mr2_prior) begin
				mr0.grant = 1; mr1.grant = 0; mr2.grant = 0; mr3.grant = 0;
			end
			else if (mr2_prior > mr0_prior) begin
				mr0.grant = 0; mr1.grant = 0; mr2.grant = 1; mr3.grant = 0;
			end
		end
		else if ((mr0_req == mr1_req) && (mr0_req > mr2_req) && (mr0_req > mr3_req)) begin
			if (mr0_prior > mr1_prior) begin
				mr0.grant = 1; mr1.grant = 0; mr2.grant = 0; mr3.grant = 0;
			end
			else if (mr1_prior > mr0_prior) begin
				mr0.grant = 0; mr1.grant = 1; mr2.grant = 0; mr3.grant = 0;
			end
		end
		else if ((mr3_req == mr2_req) && (mr2_req > mr1_req) && (mr2_req > mr0_req)) begin
			if (mr3.req == 0) begin
				mr0.grant = 0; mr1.grant = 0; mr2.grant = 1; mr3.grant = 0;
			end
			else begin
				if (mr3_prior > mr2_prior) begin
					mr0.grant = 0; mr1.grant = 0; mr2.grant = 0; mr3.grant = 1;
				end
				else if (mr2_prior > mr3_prior) begin
					mr0.grant = 0; mr1.grant = 0; mr2.grant = 1; mr3.grant = 0;
				end
			end
		end
		else if ((mr0_req == mr3_req) && (mr0_req > mr2_req) && (mr0_req > mr1_req)) begin
			if (mr3.req == 0) begin
				mr0.grant = 1; mr1.grant = 0; mr2.grant = 0; mr3.grant = 0;
			end
			else begin
				if (mr3_prior > mr0_prior) begin
					mr0.grant = 0; mr1.grant = 0; mr2.grant = 0; mr3.grant = 1;
				end
				else if (mr0_prior > mr3_prior) begin
					mr0.grant = 1; mr1.grant = 0; mr2.grant = 0; mr3.grant = 0;
				end
			end
		end
		else if ((mr1_req == mr3_req) && (mr1_req == mr0_req) && (mr1_req > mr2_req)) begin
			if ((mr0_prior > mr1_prior) && (mr0_prior > mr3_prior)) begin
				mr0.grant = 1; mr1.grant = 0; mr2.grant = 0; mr3.grant = 0;
			end
			else if ((mr1_prior > mr0_prior) && (mr1_prior > mr3_prior)) begin
				mr0.grant = 0; mr1.grant = 1; mr2.grant = 0; mr3.grant = 0;
			end
			else if ((mr3_prior > mr0_prior) && (mr3_prior > mr1_prior)) begin
				mr0.grant = 0; mr1.grant = 0; mr2.grant = 0; mr3.grant = 1;
			end
		end
		else if ((mr1_req == mr2_req) && (mr1_req > mr0_req) && (mr1_req > mr3_req)) begin
			if (mr1_prior > mr2_prior) begin
				mr0.grant = 0; mr1.grant = 1; mr2.grant = 0; mr3.grant = 0;
			end
			else if (mr2_prior > mr1_prior) begin
				mr0.grant = 0; mr1.grant = 0; mr2.grant = 1; mr3.grant = 0;
			end
		end
		else begin
			
		end

//-----------------------------------------------------------------------Address ReadData WriteData Logic-----------------------------------------------------------------
	if (mr0.grant) begin
		case(mr0.addr)
			32'hFFEF_0200:begin
				sv0.sel = 1; sv1.sel = 0; sv2.sel = 0; sv3.sel = 0;
				sv0.addr = mr0.addr;
				sv0.RW = mr0.RW;
				sv0.DataToSlave = mr0.DataToSlave;
				mr0.DataFromSlave = sv0.DataFromSlave;
			end
			32'hFFEF_1200:begin
				sv0.sel = 0; sv1.sel = 1; sv2.sel = 0; sv3.sel = 0;
				sv1.addr = mr0.addr;
				sv1.RW = mr0.RW;
				sv1.DataToSlave = mr0.DataToSlave;
				mr0.DataFromSlave = sv1.DataFromSlave;
			end
			32'hFFEF_2200:begin
				sv0.sel = 0; sv1.sel = 0; sv2.sel = 1; sv3.sel = 0;
				sv2.addr = mr0.addr;
				sv2.RW = mr0.RW;
				sv2.DataToSlave = mr0.DataToSlave;
				mr0.DataFromSlave = sv2.DataFromSlave;
			end
			32'hFFEF_3200:begin
				sv0.sel = 0; sv1.sel = 0; sv2.sel = 0; sv3.sel = 1;
				sv3.addr = mr0.addr;
				sv3.RW = mr0.RW;
				sv3.DataToSlave = mr0.DataToSlave;
				mr0.DataFromSlave = sv3.DataFromSlave;
			end
		endcase
	end
	if (mr1.grant) begin
		case(mr1.addr)
			32'hFFEF_0210:begin
				sv0.sel = 1; sv1.sel = 0; sv2.sel = 0; sv3.sel = 0;
				sv0.addr = mr1.addr;
				sv0.RW = mr1.RW;
				sv0.DataToSlave = mr1.DataToSlave;
				mr1.DataFromSlave = sv0.DataFromSlave;
			end
			32'hFFEF_1210:begin
				sv0.sel = 0; sv1.sel = 1; sv2.sel = 0; sv3.sel = 0;
				sv1.addr = mr1.addr;
				sv1.RW = mr1.RW;
				sv1.DataToSlave = mr1.DataToSlave;
				mr1.DataFromSlave = sv1.DataFromSlave;
			end
			32'hFFEF_2210:begin
				sv0.sel = 0; sv1.sel = 0; sv2.sel = 1; sv3.sel = 0;
				sv2.addr = mr1.addr;
				sv2.RW = mr1.RW;
				sv2.DataToSlave = mr1.DataToSlave;
				mr1.DataFromSlave = sv2.DataFromSlave;
			end
			32'hFFEF_3210:begin
				sv0.sel = 0; sv1.sel = 0; sv2.sel = 0; sv3.sel = 1;
				sv3.addr = mr1.addr;
				sv3.RW = mr1.RW;
				sv3.DataToSlave = mr1.DataToSlave;
				mr1.DataFromSlave = sv3.DataFromSlave;
			end
		endcase
	end
	if (mr2.grant) begin
		case(mr2.addr)
			32'hFFEF_0220:begin
				sv0.sel = 1; sv1.sel = 0; sv2.sel = 0; sv3.sel = 0;
				sv0.addr = mr2.addr;
				sv0.RW = mr2.RW;
				sv0.DataToSlave = mr2.DataToSlave;
				mr2.DataFromSlave = sv0.DataFromSlave;
			end
			32'hFFEF_1220:begin
				sv0.sel = 0; sv1.sel = 1; sv2.sel = 0; sv3.sel = 0;
				sv1.addr = mr2.addr;
				sv1.RW = mr2.RW;
				sv1.DataToSlave = mr2.DataToSlave;
				mr2.DataFromSlave = sv1.DataFromSlave;
			end
			32'hFFEF_2220:begin
				sv0.sel = 0; sv1.sel = 0; sv2.sel = 1; sv3.sel = 0;
				sv2.addr = mr2.addr;
				sv2.RW = mr2.RW;
				sv2.DataToSlave = mr2.DataToSlave;
				mr2.DataFromSlave = sv2.DataFromSlave;
			end
			32'hFFEF_3220:begin
				sv0.sel = 0; sv1.sel = 0; sv2.sel = 0; sv3.sel = 1;
				sv3.addr = mr2.addr;
				sv3.RW = mr2.RW;
				sv3.DataToSlave = mr2.DataToSlave;
				mr2.DataFromSlave = sv3.DataFromSlave;
			end
		endcase
	end
	if (mr3.grant) begin
		case(mr3.addr)
			32'hFFEF_0230:begin
				sv0.sel = 1; sv1.sel = 0; sv2.sel = 0; sv3.sel = 0;
				sv0.addr = mr3.addr;
				sv0.RW = mr3.RW;
				sv0.DataToSlave = mr3.DataToSlave;
				mr3.DataFromSlave = sv0.DataFromSlave;
			end
			32'hFFEF_1230:begin
				sv0.sel = 0; sv1.sel = 1; sv2.sel = 0; sv3.sel = 0;
				sv1.addr = mr3.addr;
				sv1.RW = mr3.RW;
				sv1.DataToSlave = mr3.DataToSlave;
				mr3.DataFromSlave = sv1.DataFromSlave;
			end
			32'hFFEF_2230:begin
				sv0.sel = 0; sv1.sel = 0; sv2.sel = 1; sv3.sel = 0;
				sv2.addr = mr3.addr;
				sv2.RW = mr3.RW;
				sv2.DataToSlave = mr3.DataToSlave;
				mr3.DataFromSlave = sv2.DataFromSlave;
			end
			32'hFFEF_3230:begin
				sv0.sel = 0; sv1.sel = 0; sv2.sel = 0; sv3.sel = 1;
				sv3.addr = mr3.addr;
				sv3.RW = mr3.RW;
				sv3.DataToSlave = mr3.DataToSlave;
				mr3.DataFromSlave = sv3.DataFromSlave;
			end
		endcase
	end

  end

endmodule
