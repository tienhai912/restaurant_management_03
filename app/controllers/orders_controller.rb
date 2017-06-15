class OrdersController < ApplicationController
  def show
    @order_dishes = current_order.order_dishes
    @order_combos = current_order.order_combos
  end

  def index
    info = params[:order]
    if info
      order = Order.find_by code: info[:code]
      if order && order.guest.email == info[:email]
        session[:order_id] = order.id
        redirect_to order_path
      else
        flash[:danger] = t "flash.order.cant_find_order"
        redirect_to orders_path
      end
    end
  end

  def create
    params[:guest_id] = session[:guest]["id"]
    session.delete :order_id if current_order.code.present?
    if current_order.id.blank?
      @order = current_order
      @order.save
      session[:order_id] = @order.id
    end
    current_order.update_attributes order_params
    flash[:success] = t "flash.order.create_success"
    render json: {path1: order_path(@order).to_s}
  end

  private
  def order_params
    params.permit :table_id, :day, :time_in, :guest_id, :code
  end
end
