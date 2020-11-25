require "math"
t_id = nil

function OnInit()
	log_path = "log.txt"
	lio = io.open(log_path, 'a')
end

function Flags2Table(flags, qtableName)
  local t={}
  if qtableName == "orders" or qtableName == "trades" or qtableName == "neg_deals" or qtableName == "neg_trades" or qtableName == "neg_deal_reports" then
    if bit.test(flags, 0) then
      t["state"] = "Active"
    elseif bit.test(flags, 1) then
      t["state"] = "Canceled"
    else
      t["state"] = "Executed"
    end
    
    if bit.test(flags, 2) then
      t["operation"] = "Продажа"
      t["operationBS"] = "S"
    else
      t["operation"] = "Купля"
      t["operationBS"] = "B"
    end
    
    if bit.test(flags, 3) then
      t["type"] = "Лимитированная"
      t["typeLM"] = "L"
    else
      t["type"] = "Рыночная"
      t["typeLM"] = "M"
    end
    
    if bit.test(flags, 5) then
      t["FILL_OR_KILL"] = 1
    else
      t["FILL_OR_KILL"] = 0
    end

    if bit.test(flags, 8) then
      t["KILL_BALANCE"] = 1
    else
      t["KILL_BALANCE"] = 0
    end
    
    if bit.test(flags, 9) then
      t["iceberg"] = 1
    else
      t["iceberg"] = 0
    end
    
  elseif qtableName == "all_trades" then
    if bit.test(flags, 0) then
      t["operation"] = "Продажа"
    elseif bit.test(flags, 1) then
      t["operation"] = "Купля"
    else
      t["operation"] = ""
    end
  
  elseif qtableName == "stop_orders" then
    if bit.test(flags, 0) then
      t["state"] = "Active"
	  t["state_num"] = 0
    elseif bit.test(flags, 1) then
      t["state"] = "Canceled"
	  t["state_num"] = 2
    else
      t["state"] = "Executed"
	  t["state_num"] = 1
    end
    
    if bit.test(flags, 2) then
      t["operation"] = "Продажа"
      t["operationBS"] = "S"
    else
      t["operation"] = "Купля"
      t["operationBS"] = "B"
    end
    
    if bit.test(flags, 3) then
      t["type"] = "Лимитированная"
      t["typeLM"] = "L"
    else
      t["type"] = "Рыночная"
      t["typeLM"] = "M"
    end

  else
    return nil
  end
  return t
end

function CreateStopOrdersSummaryTable()
	-- message('creating orders table...')

	t_id = AllocTable();
	
	col_order_num = 0
	col_ticker = 1
	col_quantity = 3
	col_order_status = 2
	col_stop_price = 4
	col_order_price = 5
	col_current_price = 6
	col_condition_status = 7
	
	AddColumn(t_id, col_order_num, "Order Number", true, QTABLE_INT_TYPE, 15)
	AddColumn(t_id, col_ticker, "Ticker", true, QTABLE_STRING_TYPE, 15)
	AddColumn(t_id, col_quantity, "Order quantity", true, QTABLE_INT_TYPE, 15)
	AddColumn(t_id, col_order_status, "Order status", true, QTABLE_STRING_TYPE , 15)
	AddColumn(t_id, col_stop_price, "Stop price", true, QTABLE_INT_TYPE, 15)
	AddColumn(t_id, col_order_price, "Order price", true, QTABLE_INT_TYPE, 15)
	AddColumn(t_id, col_current_price, "Current avg(bid, ask) price", true, QTABLE_INT_TYPE, 15)
	AddColumn(t_id, col_condition_status, "Condition status", true, QTABLE_STRING_TYPE, 15)
	
	so_count = getNumberOf('stop_orders')
	--message('so_count' .. so_count)
	
	t = CreateWindow(t_id)

	SetWindowCaption(t_id, "Orders")
	
	for i = 0, (so_count - 1) do
		row = InsertRow(t_id, -1)
		item = getItem('stop_orders', i)
		-- message('item obtained' .. tableToString(item))
		-- message(tostring(item['order_num']))
		SetCell(t_id, i, col_order_num, tostring(item['order_num']), item['order_num'])
		SetCell(t_id, i, col_ticker, tostring(item['sec_code']))
		SetCell(t_id, i, col_quantity, string.format("%.0f", item['qty']))
		fl = Flags2Table(item['flags'], 'stop_orders')
		SetCell(t_id, i, col_order_status, fl['state'] .. ' ' .. tostring(item['flags']), fl['state_num'])
		SetCell(t_id, i, col_stop_price, tostring(item['condition_price']), item['condition_price'])
		SetCell(t_id, i, col_order_price, tostring(item['price']), item['price'])
		
		
		bid_price = getParamEx(item['class_code'], item['sec_code'], "bid")['param_value']
		offer_price = getParamEx(item['class_code'], item['sec_code'], "offer")['param_value']
		current_price = (bid_price + offer_price) / 2; -- get current price for ticker
		SetCell(t_id, i, col_current_price, tostring(current_price), 0)
		
		cond_status = ""
		perc = math.abs(item['condition_price'] - current_price) / current_price
		if perc > 0.02 then
			cond_status = ">2%"
		elseif perc > 0.01 then
			cond_status = ">1% <2%"
		else
			cond_status = "OK"
		end
		cond_status = string.format("%.2f", perc * 100) .. ": " .. cond_status
		
		SetCell(t_id, i, col_condition_status, cond_status, 0)
	end	
	
	-- message('orders table has been created!')
end


function tableToString(tab)
	res = ""
	for k, v in pairs(tab) do
		res = res .. tostring(k) .. ': ' .. tostring(v) .. '; '
	end
	return "{ " .. res .. " }"
end

function OnStop()
	lio:close()
end

function main(path)

	CreateStopOrdersSummaryTable()
	
	-- while isConnected() == 1 do
	--	message("Hi" .. idx)
		sleep(1000)
	--	idx = idx + 1
	--	InsertRow(t_id, -1)
	
end