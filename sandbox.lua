require "math"
t_id = nil

col_idx = {}

col_idx["Order number"] = 0
col_idx["Ticker"] = 1
col_idx["Order quantity"] = 4
col_idx["Order status"] = 3
col_idx["Flags"] = 2
col_idx["Stop price"] = 5
col_idx["Order price"] = 6
col_idx["Current avg(bid, ask) price"] = 7
col_idx["Current percent"] = 8
col_idx["Levels"] = 9

function OnInit()
	log_path = "log.txt"
	lio = io.open(log_path, 'a')
	is_stop_requested = false
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

function UpdateStopOrdersSummaryTable(t_id)
	Clear(t_id)
	
	so_count = getNumberOf('stop_orders')
	for i = 0, (so_count - 1) do
		row = InsertRow(t_id, -1)
		item = getItem('stop_orders', i)
		
		SetCell(t_id, i, col_idx["Order number"], tostring(item['order_num']), item['order_num'])
		SetCell(t_id, i, col_idx["Ticker"], tostring(item['sec_code']))
		SetCell(t_id, i, col_idx["Order quantity"], string.format("%.0f", item['qty']))
		fl = Flags2Table(item['flags'], 'stop_orders')
		SetCell(t_id, i, col_idx["Flags"], tostring(item['flags']), item['flags'])
		SetCell(t_id, i, col_idx["Order status"], fl['state'], fl['state_num'])
		SetCell(t_id, i, col_idx["Stop price"], tostring(item['condition_price']), item['condition_price'])
		SetCell(t_id, i, col_idx["Order price"], tostring(item['price']), item['price'])
		
		
		bid_price = getParamEx(item['class_code'], item['sec_code'], "bid")['param_value']
		offer_price = getParamEx(item['class_code'], item['sec_code'], "offer")['param_value']
		current_price = (bid_price + offer_price) / 2; -- get current price for ticker
		SetCell(t_id, i, col_idx["Current avg(bid, ask) price"], tostring(current_price), 0)
		
		cond_status = ""
		perc = math.abs(item['condition_price'] - current_price) / current_price
		if perc > 0.02 then
			cond_status = ">2%"
		elseif perc > 0.01 then
			cond_status = ">1% <2%"
		else
			cond_status = "OK"
		end
		
		SetCell(t_id, i, col_idx["Current percent"], string.format("%.2f", perc * 100), 0)
		
		
		SetCell(t_id, i, col_idx["Levels"], cond_status, 0)
	end	
end

function CreateStopOrdersSummaryTable()
	-- message('creating orders table...')

	t_id = AllocTable();
	
	key = "Order number"
	AddColumn(t_id, col_idx[key], key, true, QTABLE_INT_TYPE, 15)
	
	key = "Ticker"
	AddColumn(t_id, col_idx[key], key, true, QTABLE_STRING_TYPE, 15)
	
	key = "Order quantity"
	AddColumn(t_id, col_idx[key], key, true, QTABLE_INT_TYPE, 15)
	
	key = "Order status"
	AddColumn(t_id, col_idx[key], key, true, QTABLE_STRING_TYPE , 15)
	
	key = "Stop price"
	AddColumn(t_id, col_idx[key], key, true, QTABLE_INT_TYPE, 15)
	
	key = "Order price"
	AddColumn(t_id, col_idx[key], key, true, QTABLE_INT_TYPE, 15)
	
	key = "Current avg(bid, ask) price"
	AddColumn(t_id, col_idx[key], key, true, QTABLE_INT_TYPE, 15)
	
	key = "Current percent"
	AddColumn(t_id, col_idx[key], key, true, QTABLE_STRING_TYPE, 15)
	
	key = "Flags"
	AddColumn(t_id, col_idx[key], key, true, QTABLE_INT_TYPE, 15)
	
	key = "Levels"
	AddColumn(t_id, col_idx[key], key, true, QTABLE_STRING_TYPE, 15)
	
	t = CreateWindow(t_id)

	SetWindowCaption(t_id, "Stop orders")
	
	return t_id
	
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
	is_stop_requested = true
	lio:close()
end

function main(path)

	t_id = CreateStopOrdersSummaryTable()
	
	while isConnected() == 1 and not is_stop_requested do
		UpdateStopOrdersSummaryTable(t_id)
		sleep(3000)
	end
end