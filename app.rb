# encoding: cp866

# текущее состояние поля
class Board

	# константы

	# номера ячеек "по улитке", чтобы было непонятнее. 
	# можно поменять, но только вместе с выигрышными комбинациями
	Numbers = [ [ 1, 2, 3 ], [ 8, 9, 4 ], [ 7, 6, 5 ] ]

	# выигрышные комбинации - три в ряд
	Win_combinations = [ 
		[ 1, 2, 3 ], [ 8, 9, 4 ], [ 7, 6, 5 ],	# 3 горизонтали
		[ 1, 8, 7 ], [ 2, 9, 6 ], [ 3, 4, 5 ],	# 3 вертикали
		[ 1, 9, 5 ], [ 3, 9, 7 ]				# 2 диагонали
	]

	# крестик и нолик
	Cross = 'X'
	Zero = 'O'

	attr_reader :depth

	def initialize depth, board
		# установленные крестики и нолики
		@board = board
		# количество ходов с начала игры
		# нужно для подсчёта очков
		@depth = depth
	end

	# красивый вывод поля
	def display
	
		Numbers.each do |row|				# по рядам сверху вниз
			
			row.each do |item|				# по элементам слева направо
		
				if @board[item]				# если стоит крестик или нолик
					print @board[item]		# вывод
				else
					print item				# в незанятые ячейки пишем их номер для удобства ввода
				end

				print ' '
			end

			puts
	
		end
	
	end

	# есть ли три фигуры в ряд?
	def win? figure
		
		moves = @board.select{ |k, v| v == figure }.keys

		Win_combinations.each do |combination|

			# в каждом элементе combination есть player
			return true if (combination - moves).empty?

		end

		return false

	end

	# окончена ли игра?
	def game_end?

		# если некуда ходить - конец
		return true if @board.size == 9

		# если кто-то победил - тоже
		return true if win?( Cross ) || win?( Zero )

		return false
	end

	# копия доски, потому что нужно "играть"
	# при принятии решения
	def move figure, position

		# создаём копию хэша
		# если просто сделать = объекты будут одинаковые
		new_board = @board.clone
		new_board[position] = figure

		return Board.new @depth + 1, new_board
	
	end

	# массив пустых ячеек
	def possible_moves
		
		moves = []
		
		(1..9).each do |move|
			# добавляем все ключи, которых в board нет
			moves << move unless @board.has_key? move
		end

		return moves

	end

end

# положительный счёт - компьютер победил,
# отрицательный проиграл
# если ничья или игра не закончена - 0
def score board

	# чем дольше игра, тем меньше проигрыш
	# сделано, чтобы компьютер не сдавался заранее
	return board.depth - 10 if board.win? @player

	# чем короче игра, тем больше выигрыш
	return 10 - board.depth if board.win? @computer

	# никто не победил
	return 0

end

# ходим во все клетки с рекурсией и 
# находим ту, выигрыш в которой максимален
def computer_move board

	if board.game_end?
		return score board
	end

	# ход => максимальный выигрыш
	moves = {}

	board.possible_moves.each do |move|
		new_board = board.move @computer, move
		score = player_move new_board
		moves[move] = score
	end

	# хотим победить побыстрее
	# или проиграть попозже
	best = moves.values.max
	
	# выбираем куда ходить,
	# если вариантов несколько, берём случайный
	bestmoves = moves.select{ |k,v| v == best }.keys
	@choice = bestmoves[ rand( bestmoves.size ) ]

	# возвращаем выигрыш
	return best

end

# представляем, что игрок такой же умный и хочет
# минимизировать выигрыш компьютера
def player_move board

	if board.game_end?
		return score board
	end

	# ход => максимальный выигрыш
	moves = {}

	board.possible_moves.each do |move|
		new_board = board.move @player, move
		score = computer_move new_board
		moves[move] = score
	end

	# минимизируем выигрыш компьютера
	best = moves.values.min
	
	# выбираем куда ходить,
	# если вариантов несколько, берём случайный
	bestmoves = moves.select{ |k,v| v == best }.keys
	@choice = bestmoves[ rand( bestmoves.size ) ]

	# возвращаем выигрыш
	return best

end

# main

game = Board.new 0, {}

print 'Будешь ходить первым? (Y/N) '
answer = gets.strip.upcase

@player = Board::Cross
@computer = Board::Zero

unless answer == 'Y'
	@player = Board::Zero
	@computer = Board::Cross

	# computer_move устанавливает переменную @choice
	computer_move game
	game = game.move @computer, @choice
end

until game.game_end?
 	
 	# вывод поля для удобства ввода
	game.display

	# фильтр ввода
	move = 0
	possible_moves = game.possible_moves

	until possible_moves.member? move
		print 'Твой ход: '
		move = gets.to_i
	end

	# ход игрока
	game = game.move @player, move

	break if game.game_end?

	# ход компьютера
	computer_move game
	game = game.move @computer, @choice

end

# вывод результата
game.display

result = score game

if result < 0
	# если вылезла эта надпись,
	# значит в программе ошибка
	# победить хорошего игрока нельзя
	puts 'Ты подебил'
elsif result > 0
	puts 'Я победил'
else
	puts 'Ничья'	
end