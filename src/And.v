module And
(
	data1_i,
	data2_i,
	data_o
);

input      data1_i;
input      data2_i;
output reg data_o;

always @(data1_i or data2_i)
begin
	data_o = data1_i & data2_i;
end

endmodule

/*
input data1_i = brach
input data2_i = 1/0 由 == 決定 
    equal 就跳
    不equal 就不跳
*/