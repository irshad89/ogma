class Kewpa17Pdf < Prawn::Document
  def initialize(disposal, view)
    super({top_margin: 50, page_size: 'A4', page_layout: :portrait })
    @disposals = disposal
    @view = view
    font "Times-Roman"
    text "KEW.PA-17", :align => :right, :size => 16, :style => :bold
    move_down 20
    text "LAPORAN LEMBAGA PEMERIKSA ASET ALIH KERAJAAN", :align => :center, :size => 14, :style => :bold
    move_down 20
    text "KEMENTERIAN/JABATAN:  KOLEJ SAINS KESIHATAN BERSEKUTU JOHOR BAHRU", :align => :left, :size => 10
    tab
    table1
    table2
    table3
  
   
  end
  
  def tab
    data = [["","","","","", "", "", "HARGA PEROLEHAN ASAL", "NILAI SEMASA", "", ""]]
    
    table(data , :column_widths => [20, 40, 50, 35, 40, 45, 40, 80, 80, 65], :cell_style => { :size => 6}) do
     row(0).columns(0).borders = [:left, :right, :top]
     row(0).columns(1).borders = [:left, :right, :top]
     row(0).columns(2).borders = [:left, :right, :top]
     row(0).columns(3).borders = [:left, :right, :top]
     row(0).columns(4).borders = [:left, :right, :top]
     row(0).columns(5).borders = [:left, :right, :top]
     row(0).columns(6).borders = [:left, :right, :top]
     row(0).columns(10).borders = [:left, :right, :top]
     row(0).columns(11).borders = [:left, :right, :top]
     row(0).columns(12).borders = [:left, :right, :top]
     self.width = 555
    end
    
  end
  def table1
    
    table line_item_rows  do
      columns(0).width = 20
      columns(0).borders = [:left, :right, :bottom]
      columns(1).width = 40
      columns(1).borders = [:left, :right, :bottom]
      columns(2).width = 50
      columns(2).borders = [:left, :right, :bottom]
      columns(3).width = 35
      columns(3).borders = [:left, :right, :bottom]
      columns(4).width = 40
      columns(4).borders = [:left, :right, :bottom]
      columns(5).width = 45
      columns(5).borders = [:left, :right, :bottom]
      columns(6).width = 40
      columns(6).borders = [:left, :right, :bottom]
      columns(7).width = 40
      columns(8).width = 40
      columns(9).width = 40
      columns(10).width = 40
      columns(10).borders = [:left, :right, :bottom]
      columns(11).width = 60
      columns(11).borders = [:left, :right, :bottom]
      columns(11).width = 65
      columns(12).borders = [:left, :right, :bottom]
      self.row_colors = ["FEFEFE", "FFFFFF"]
      self.header = true
      self.cell_style = { size: 6 }
      self.width = 555
      header = true
    end
  end
  def line_item_rows
   
      counter = counter || 0
      header = [[ 'Bil', 'JABATAN/ BAHAGIAN', "KETERANGAN ASET", 'UNIT', 'KUANTITI', 'TARIKH PEMBELIAN','TEMPOH DIGUNAKAN / SIMPANAN',
        'SEUNIT (RM)', 'JUMLAH (RM)', 'SEUNIT (RM)', 'JUMLAH (RM)', 'NYATAKAN KEADAAN ASET DENGAN JELAS', 'SYOR KAEDAH PELUPUSAN DAN JUSTIFIKASI']]
      header +
        @disposals.map do |disposal|
          
          quantiti = "#{disposal.try(:asset).try(:quantity)}"
          if quantiti.to_i < 1

           a = "#{disposal.try(:asset).try(:purchaseprice)}"
           b = 1
           c = "#{disposal.current_value}"
           total = a.to_i * b.to_i 
           totalcurrent = c.to_i * b.to_i 
            quan = 1
       else
           a = "#{disposal.try(:asset).try(:purchaseprice)}"
           b = "#{disposal.try(:asset).try(:quantity)}"
           c = "#{disposal.current_value}"
           total = a.to_i * b.to_i 
           totalcurrent = c.to_i * b.to_i 
            quan = "#{disposal.try(:asset).try(:quantity)}"
         end
         
        ["#{counter += 1}", "", "#{disposal.try(:asset).try(:assetcode)} #{disposal.try(:asset).try(:name)}", "" , quan ,"#{disposal.try(:asset).try(:purchasedate).try(:strftime, "%d/%m/%y")}", 
          "#{Date.today - disposal.try(:asset).try(:purchasedate)} days", @view.currency(disposal.try(:asset).try(:purchaseprice).to_f), @view.currency(total.to_f), @view.currency(disposal.current_value.to_f), @view.currency(totalcurrent.to_f), "", "" ]

      end
      
end

def table2
   count = sum = 0
  @disposals.map do |disposal|
    
    quantiti = "#{disposal.try(:asset).try(:quantity)}"
    if quantiti.to_i < 1

     a = "#{disposal.try(:asset).try(:purchaseprice)}"
     b = 1
     c = "#{disposal.current_value}"
     total = a.to_i * b.to_i 
     totalcurrent = c.to_i * b.to_i 
 else
     a = "#{disposal.try(:asset).try(:purchaseprice)}"
     b = "#{disposal.try(:asset).try(:quantity)}"
     c = "#{disposal.current_value}"
     total = a.to_i * b.to_i 
     totalcurrent = c.to_i * b.to_i 
   end
   count += total
   sum += totalcurrent
 end
  data3 = [["","JUMLAH KESELURUHAN", @view.currency(count.to_f),"", @view.currency(sum.to_f),""]]
  
  table(data3, :column_widths => [185, 125, 40,  40, 40], :cell_style => { :size => 6}) do
    self.width = 555
    columns(1).align = :right
    
  end
  move_down 20
end
  def table3
   data = [["Tarikh pelantikan Lembaga pemeriksa #{'.'*60}", "Tandatangan ","#{'.'*60} (pengerusi)"],
   [ "Tarikh pemeriksaan #{'.'*60}", "Nama ", "#{'.'*60}"],
   ["Tempat pemeriksaan #{'.'*60}", "Tandatangan", "#{'.'*60}"],
   ["","Nama","#{'.'*60}"],
   ["","Jawatan", "#{'.'*60}"],
   ["","","*(Ruangan boleh ditambah jika ahli Lembaga Pemeriksa Lebih daripada 2 orang)"]]
   
   table(data, :column_widths => [200, 90, ], :cell_style => { :size => 9}) do
     columns(0).borders = []
     columns(1).borders = []
     columns(2).borders = []
  end
end
end