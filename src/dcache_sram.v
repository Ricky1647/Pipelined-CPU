module dcache_sram
(
    clk_i,    // system clock cycle 
    rst_i,    // reset 
    addr_i,   
    // address from cache_sram_index
    // cache_sram_index from cpu_index
    // cpu_index from cpu_addr_i [8:5] 即index
    // 用來找是第幾個tag
    tag_i,    
    // ->cache_sram_tag ->{1'b1, cache_dirty, cpu_tag}; 
    // {valid bit, dirty bit , tag}
    data_i,
    // cache_sram_data-> (hit) ? w_hit_data : mem_data_i;
    // mem_data_i **Data Mem Interface**
    enable_i,
    write_i,
    //write_hit_i,
    tag_o,
    data_o,
    hit_o
);

// I/O Interface from/to controller
input              clk_i;
input              rst_i;
input    [3:0]     addr_i;
input    [24:0]    tag_i;
input    [255:0]   data_i;
input              enable_i;
input              write_i;

output   [24:0]    tag_o;
output   [255:0]   data_o;
output             hit_o;


// Memory
reg      [24:0]    tag [0:15][0:1];
// 2 way 所以分成兩組，每一組有16 Blocks   
reg      [255:0]   data[0:15][0:1];
reg                LRU_older [0:15]; // append*
integer            i, j;
// append*
reg   [24:0]    tag_o;
reg   [255:0]   data_o;
reg             hit_o;

wire             hit_0;
wire             hit_1;
// append*
//input              write_hit_i;

// Write Data      
// 1. Write hit
// 2. Read miss: Read from memory

assign hit_0 = (tag_i[22:0] == tag[addr_i][0][22:0]) && tag[addr_i][0][24];
assign hit_1 = (tag_i[22:0] == tag[addr_i][1][22:0]) && tag[addr_i][1][24];
// Write Policy
always@(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
        for (i=0;i<16;i=i+1) begin
            LRU_older[i] <= 1'b0;
            for (j=0;j<2;j=j+1) begin
                tag[i][j] <= 25'b0;
                data[i][j] <= 256'b0;
            end
        end
    end
    if (enable_i && write_i) begin
        // TODO: Handle your write of 2-way associative cache + LRU here
        if (hit_0) begin
          tag[addr_i][0] = tag_i;
          data[addr_i][0] = data_i;
          LRU_older[addr_i] = 1'b1;
        end
        else if (hit_1) begin
            tag[addr_i][1] = tag_i;
            data[addr_i][1] = data_i;
            LRU_older[addr_i] = 1'b0;
        end
        else begin //代表沒有hit wrtie miss implement LRU
          if (LRU_older[addr_i] == 1'b0) begin
            tag[addr_i][0] = tag_i;
            data[addr_i][0] = data_i;
            LRU_older[addr_i] = 1'b1;
          end
          else if (LRU_older[addr_i]==1'b1) begin
            tag[addr_i][1] = tag_i;
            data[addr_i][1] = data_i;
            LRU_older[addr_i] = 1'b0;
          end
        end
    end
end

// Read Data      
// TODO: tag_o=? data_o=? hit_o=?
always @(*) begin
    if(enable_i) begin
        if (hit_0) begin //firt way hit 
            hit_o <= 1'b1;
            data_o <= data[addr_i][0];
            tag_o <= tag[addr_i][0];
            LRU_older[addr_i]=1'b1;
        end
        else if (hit_1) begin
            hit_o <= 1'b1;
            data_o <= data[addr_i][1];
            tag_o <= tag[addr_i][1];
            LRU_older[addr_i]=1'b0;
        end
        else begin
            hit_o <= 1'b0;
            if (LRU_older[addr_i]==1'b1) begin
              tag_o <= tag[addr_i][1];
              if (data[addr_i][1]==0)begin
                data_o <= data_i; //直接用memory 的 data
              end
              else begin
                data_o <= data[addr_i][1];
              end
            end
            else begin
              tag_o <= tag[addr_i][0];
              if(data[addr_i][0]==0)begin
                data_o <= data_i;
              end
              else begin
                data_o <= data[addr_i][0];
              end
            end
            end
        end
    // else begin
    //   hit_o <= 1'b0;
    //   data_o <= data_i;
    //   tag_o <= tag_i;
    // end
end
endmodule
