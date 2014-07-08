class Kewpa28Pdf < Prawn::Document
  def initialize(asset_loss, view)
    super({top_margin: 50, page_size: 'A4', page_layout: :portrait })
    @asset_loss = asset_loss
    @view = view
    font "Times-Roman"
    text "KEW.PA-28", :align => :right, :size => 16, :style => :bold
    move_down 20
    text "LAPORAN AWAL KEHILANGAN ASET ALIH KERAJAAN", :align => :center, :size => 14, :style => :bold
    move_down 30
    text "Nyatakan :-", :align => :left, :size => 12
    move_down 20
    text "1.      Keterangan Aset Yang Hilang", :align => :left, :size => 12
    move_down 10
    text "  (a)   Jenis Aset  : #{@asset_loss.try(:asset).try(:typename)}", :align => :left, :size => 12, :indent_paragraphs => 30
    move_down 5
    text "  (b)   Jenama dan Model  : #{@asset_loss.try(:asset).try(:name)} #{@asset_loss.try(:asset).try(:modelname)}", :align => :left, :size => 12, :indent_paragraphs => 30
    move_down 5
    text "  (c)   Kuantiti  :", :align => :left, :size => 12, :indent_paragraphs => 30
    move_down 5
    text "  (d)   Tarikh Perolehan  : #{@asset_loss.try(:asset).try(:purchasedate).try(:strftime, "%d/%m/%y")}", :align => :left, :size => 12, :indent_paragraphs => 30
    move_down 5
    text "  (e)   Harga Perolehan Asal  : #{@asset_loss.try(:asset).try(:purchaseprice)}", :align => :left, :size => 12, :indent_paragraphs => 30
    move_down 20
    text "2.      Tempat sebenar di mana kehilangan berlaku", :align => :left, :size => 12
    text "#{@asset_loss.try(:location).try(:location_list)}", :align => :left, :size => 12, :indent_paragraphs => 30
    move_down 20
    text "3.      Tarikh kehilangan berlaku atau diketahui", :align => :left, :size => 12
    text "#{@asset_loss.try(:lost_at).try(:strftime, "%d/%m/%y")}", :align => :left, :size => 12, :indent_paragraphs => 30
    move_down 20
    text "4.      Cara bagaimana kehilangan berlaku", :align => :left, :size => 12
    text "#{@asset_loss.try(:how_desc)}", :align => :left, :size => 12, :indent_paragraphs => 30
    move_down 20
    text "5.      Nama dan jawatan pegawai yang akhir sekali menyimpan/mengguna aset yang hilang", :align => :left, :size => 12
    text "#{@asset_loss.try(:handled_by).try(:staff).try(:name)}", :align => :left, :size => 12, :indent_paragraphs => 30
    move_down 20
    text "6.      Sama ada seseorang pegawai yang difikirkan prima facie bertanggungjawab ke atas kehilangan itu. Jika ya, nama dan jawatannya", :align => :left, :size => 12
    text "#{@asset_loss.try(:is_prima_facie?) ? "Nama" : "Tiada"}", :align => :left, :size => 12, :indent_paragraphs => 30
    move_down 20
    text "7.      Sama ada seseorang pegawai telah ditahan kerja", :align => :left, :size => 12
    text "#{@asset_loss.try(:is_staff_action?) ? "Ada" : "Tiada"}", :align => :left, :size => 12, :indent_paragraphs => 30
    move_down 20
    text "8.      No. Rujukan dan Tarikh Laporan Polis", :align => :left, :size => 12
    text "#{@asset_loss.try(:police_report_code)}", :align => :left, :size => 12, :indent_paragraphs => 30
    move_down 20
    text "9.      Langkah-langkah sedia ada untuk menggelakkan kehilangan itu berlaku", :align => :left, :size => 12
    text "#{@asset_loss.try(:preventive_measures)}", :align => :left, :size => 12, :indent_paragraphs => 30
    move_down 20
    text "10.      Langkah-langkah segera yang diambil bagi mencegah berulangnya kejadian itu", :align => :left, :size => 12
    text "#{@asset_loss.try(:new_measures)}", :align => :left, :size => 12, :indent_paragraphs => 30
    move_down 20
    text "11.      Catatan", :align => :left, :size => 12
    text "#{@asset_loss.try(:notes)}", :align => :left, :size => 12, :indent_paragraphs => 30
    move_down 20
    
    
    text "Nama        :	", :align => :left, :size => 12, :indent_paragraphs => 250
    text "Jawatan     :	", :align => :left, :size => 12, :indent_paragraphs => 250
    text "Tarikh      :	", :align => :left, :size => 12, :indent_paragraphs => 250
    text "Cop Jabatan :	", :align => :left, :size => 12, :indent_paragraphs => 250
    
   
  end
  
  
end