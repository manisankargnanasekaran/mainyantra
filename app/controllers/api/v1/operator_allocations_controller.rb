module Api
  module V1
class OperatorAllocationsController < ApplicationController
  before_action :set_operator_allocation, only: [:show, :update, :destroy]

  # GET /operator_allocations
  def index
   @operator_allocations = OperatorAllocation.where(:machine_id=>Tenant.find(params[:tenant_id]).machines.ids).where(from_date:Date.today-7..Date.today+20).order("id DESC")
# @operator_allocations = OperatorAllocation.where(tenant_id:params[:tenant_id],created_at:Date.today-5..Date.today+20).order("id DESC")

    render json: @operator_allocations
  end

  # GET /operator_allocations/1
  def show
    render json: @operator_allocation
  end

  # POST /operator_allocations
#  def create
#    @operator_allocation = OperatorAllocation.new(operator_allocation_params)
#    if @operator_allocation.save
#      render json: @operator_allocation
#    else
#      render json: @operator_allocation.errors
#    end
#  end
=begin
  def create
   if @operator_allocation = OperatorAllocation.create(operator_allocation_params)
      (@operator_allocation.from_date..@operator_allocation.to_date).map do |date|
      OperatorMappingAllocation.create(:date=>date,:operator_id=>@operator_allocation.operator_id,:operator_allocation_id=>@operator_allocation.id)
      end
      render json: @operator_allocation
    else
      render json: @operator_allocation.errors
    end
  end
#---------------------------------new------------------#
  def create

    @operator_allocation = OperatorAllocation.new(operator_allocation_params)
    unless OperatorAllocation.where(:operator_id=>@operator_allocation.operator_id, :shifttransaction_id=>@operator_allocation.shifttransaction_id, :machine_id=>@operator_allocation.machine_id,:tenant_id=>@operator_allocation.tenant_id,:from_date=>@operator_allocation.from_date,:to_date=>@operator_allocation.to_date).present?

    (@operator_allocation.from_date..@operator_allocation.to_date).map do |date|

       if  OperatorMappingAllocation.where(:date=>date).present?

          unless OperatorMappingAllocation.where(:date=>date,:operator_id=>@operator_allocation.operator_id).present?

            unless OperatorAllocation.where(:operator_id=>@operator_allocation.operator_id,:shifttransaction_id=>@operator_allocation.shifttransaction_id, :machine_id=>@operator_allocation.machine_id,:tenant_id=>@operator_allocation.tenant_id).present?
              if OperatorAllocation.where(:shifttransaction_id=>@operator_allocation.shifttransaction_id, :machine_id=>@operator_allocation.machine_id,:tenant_id=>@operator_allocation.tenant_id).present?
                puts "not ok"
                return render json: {:msg=>"Invalid Operator or Date"}
              else
                puts "ok"
              end
            else
              puts "not ok"
              return render json: {:msg=>"Invalid Operator or Date"}
            end
          else
           if OperatorAllocation.where(:shifttransaction_id=>@operator_allocation.shifttransaction_id, :machine_id=>@operator_allocation.machine_id,:tenant_id=>@operator_allocation.tenant_id).present?
                puts "not ok"
                return render json: {:msg=>"Invalid Operator or Date"}
              else
                puts "ok"
              end
           end
        end
      end
    if @operator_allocation.save
       (@operator_allocation.from_date..@operator_allocation.to_date).map do |date|
        OperatorMappingAllocation.create(:date=>date,:operator_id=>@operator_allocation.operator_id,:operator_allocation_id=>@operator_allocation.id)
       end
       render json: @operator_allocation
    else
       render json: @operator_allocation.errors
    end
  else
      render json: {:msg=>"Invalid Operator or Date"}
  end
  end
=end

# POST /operator_allocations
=begin
  def create
    @operator_allocation = OperatorAllocation.new(operator_allocation_params)
    unless OperatorAllocation.where(:operator_id=>@operator_allocation.operator_id, :shifttransaction_id=>@operator_allocation.shifttransaction_id, :machine_id=>@operator_allocation.machine_id,:tenant_id=>@operator_allocation.tenant_id,:from_date=>@operator_allocation.from_date,:to_date=>@operator_allocation.to_date).present?
    (@operator_allocation.from_date..@operator_allocation.to_date).map do |date|
       if  OperatorMappingAllocation.where(:date=>date).present?
            unless OperatorMappingAllocation.where(:date=>date,:operator_id=>@operator_allocation.operator_id).present?
                  unless OperatorAllocation.where(:operator_id=>@operator_allocation.operator_id,:shifttransaction_id=>@operator_allocation.shifttransaction_id, :machine_id=>@operator_allocation.machine_id,:tenant_id=>@operator_allocation.tenant_id).present?
                    if OperatorAllocation.where(:shifttransaction_id=>@operator_allocation.shifttransaction_id, :machine_id=>@operator_allocation.machine_id,:tenant_id=>@operator_allocation.tenant_id).present?
                      puts "not ok"
                      return render json: {:msg=>"Invalid Operator or Date"}
                    else
                      puts "ok"
                    end
                  else
                    puts "not ok"
                    return render json: {:msg=>"Invalid Operator or Date"}
                  end
            else
             if OperatorAllocation.where(:operator_id=>@operator_allocation.operator_id,:shifttransaction_id=>@operator_allocation.shifttransaction_id, :machine_id=>@operator_allocation.machine_id,:tenant_id=>@operator_allocation.tenant_id).present?
                  puts "not ok"
                  return render json: {:msg=>"Invalid Operator or Date"}
                else
                  puts "ok"
                end
             end 
        end
      end
    if @operator_allocation.save
       (@operator_allocation.from_date..@operator_allocation.to_date).map do |date|
        OperatorMappingAllocation.create(:date=>date,:operator_id=>@operator_allocation.operator_id,:operator_allocation_id=>@operator_allocation.id)
       end
       render json: @operator_allocation
    else
       render json: @operator_allocation.errors
    end
  else
      render json: {:msg=>"Invalid Operator or Date"}
  end
  end
=end
  
  def create
    @operator_allocation = OperatorAllocation.new(operator_allocation_params)
    unless OperatorAllocation.where(:operator_id=>@operator_allocation.operator_id, :shifttransaction_id=>@operator_allocation.shifttransaction_id, :machine_id=>@operator_allocation.machine_id,:tenant_id=>@operator_allocation.tenant_id,:from_date=>@operator_allocation.from_date,:to_date=>@operator_allocation.to_date).present?
    (@operator_allocation.from_date..@operator_allocation.to_date).map do |date|
       if  OperatorMappingAllocation.where(:date=>date).present?
            unless OperatorMappingAllocation.where(:date=>date,:operator_id=>@operator_allocation.operator_id).present?
                 last_ops = OperatorAllocation.where(:shifttransaction_id=>@operator_allocation.shifttransaction_id, :machine_id=>@operator_allocation.machine_id,:tenant_id=>@operator_allocation.tenant_id).last
                 if last_ops != nil
                      a=last_ops.from_date.strftime("%Y").to_i;b=last_ops.from_date.strftime("%m").to_i;c=last_ops.from_date.strftime("%d").to_i
                      a1=last_ops.to_date.strftime("%Y").to_i;b1=last_ops.to_date.strftime("%m").to_i;c1=last_ops.to_date.strftime("%d").to_i
                      a2=date.strftime("%Y").to_i;b2=date.strftime("%m").to_i; c2=date.strftime("%d").to_i
                      first_date = Date.new(a, b, c)
                     last_date = Date.new(a1, b1, c1)
                     range =(first_date..last_date)
                    if range.include?(Date.new(a2, b2, c2))
                    #if OperatorAllocation.where(:shifttransaction_id=>@operator_allocation.shifttransaction_id, :machine_id=>@operator_allocation.machine_id,:tenant_id=>@operator_allocation.tenant_id).present?
                      puts "not ok"
                      return render json: {:msg=>"Invalid Operator or Date"}
                    else
                      puts "ok"
                    end
                    end
            else
last_ops = OperatorAllocation.where(:shifttransaction_id=>@operator_allocation.shifttransaction_id, :machine_id=>@operator_allocation.machine_id,:tenant_id=>@operator_allocation.tenant_id).last
 if last_ops != nil
                      a=last_ops.from_date.strftime("%Y").to_i;b=last_ops.from_date.strftime("%m").to_i;c=last_ops.from_date.strftime("%d").to_i
                      a1=last_ops.to_date.strftime("%Y").to_i;b1=last_ops.to_date.strftime("%m").to_i;c1=last_ops.to_date.strftime("%d").to_i
                      a2=date.strftime("%Y").to_i;b2=date.strftime("%m").to_i; c2=date.strftime("%d").to_i
                      first_date = Date.new(a, b, c)
                     last_date = Date.new(a1, b1, c1)
                     range =(first_date..last_date)
             if range.include?(Date.new(a2, b2, c2))
             #if OperatorAllocation.where(:operator_id=>@operator_allocation.operator_id,:shifttransaction_id=>@operator_allocation.shifttransaction_id, :machine_id=>@operator_allocation.machine_id,:tenant_id=>@operator_allocation.tenant_id,from_date:date,to_date:date).present?
                 puts "not ok"
                  return render json: {:msg=>"Invalid Operator or Date"}
                else
                  puts "ok"
                end
             end
             end 
        end
      end
    if @operator_allocation.save
       (@operator_allocation.from_date..@operator_allocation.to_date).map do |date|
        OperatorMappingAllocation.create(:date=>date,:operator_id=>@operator_allocation.operator_id,:operator_allocation_id=>@operator_allocation.id)
       end
       render json: @operator_allocation
    else
       render json: @operator_allocation.errors
    end
  else
      render json: {:msg=>"Invalid Operator or Date"}
  end
end
 

  # PATCH/PUT /operator_allocations/1
  def update
    if @operator_allocation.update(operator_allocation_params)
      render json: @operator_allocation
    else
      render json: @operator_allocation.errors
    end
  end

  # DELETE /operator_allocations/1
  def destroy
    @operator_allocation.destroy
     if @operator_allocation.destroy
      render json: true
    else
      render json: false
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_operator_allocation
      @operator_allocation = OperatorAllocation.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
   # def operator_allocation_params
   #   params.require(:operator_allocation).permit(:operator_id, :shifttransaction_id, :machine_id, :description)
   # end
    def operator_allocation_params
      params.require(:operator_allocation).permit(:operator_id, :shifttransaction_id, :machine_id, :description,:tenant_id,:from_date,:to_date)
    end
end
end
end
