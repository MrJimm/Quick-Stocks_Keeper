require 'State'
require 'utils'
require 'OpenPositionState'

OpeningPositionState = {}

extended(OpeningPositionState , State)

function OpeningPositionState:processState(ticker_config, stocks_data)
    print('- check if stoploss in needed to reset')
    print('if yes - move it and return to the same state')
    print('else if stop limit have been executed - check if position is here. If not - write error. If yes - set stop-loss and go to HavingPosition state')
end