class Asset::StationeriesController < ApplicationController
  before_action :set_stationery, only: [:show, :edit, :update, :destroy]
  
  def index
    @stationeries = Stationery.order(code: :asc).page(params[:page]||1)
  end
  
  def show
  end
  
  def edit
  end
  
  def update
    @stationery = Stationery.find(params[:id])

    respond_to do |format|
      if @stationery.update(stationery_params)
        format.html { redirect_to asset_stationery_path, notice: (t 'stationery.title')+(t 'actions.updated')}
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @stationery.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def kewps13
    @lead = Position.find(1)
    @stationeries = Stationery.order(code: :asc)
    respond_to do |format|
      format.pdf do
        pdf = Kewps13Pdf.new(@stationeries, view_context, @lead)
        send_data pdf.render, filename: "kewps13-{Date.today}",
                              type: "application/pdf",
                              disposition: "inline"
      end
    end
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_stationery
      @stationery = Stationery.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def stationery_params
      params.require(:stationery).permit(:code, :category, :unittype, :maxquantity, :minquantity, damages_attributes: [:id, :description,:reported_on,:document_id,:location_id])
    end
end