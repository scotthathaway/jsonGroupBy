parseFormula = (formula, formula_info) ->
	actions = ['CountAll','SumAll','MinAll','MaxAll','AvgAll','Sum','Count','Min','Max','Avg']
	# for field, formula of formula_data
	# console.log formula
	for name in formula_info
		for action in actions
			data = "data"
			if action=="Sum" or action=="Count" or action=="Min" or action=="Max" or action=="Avg" then data = "gdata"
			af = action + '.' + name
			if formula.indexOf(af) > -1
				formula_expanded = '(' + getFormula(af, data) + ')'
				formula = formula.replace(af,formula_expanded)
	return formula

getFormula = (field,data='') ->
	if data == '' then data = 'data'
	parts  = field.split('.')
	name   = parts[1]
	action = parts[0]
	if parts.length > 2 then return field
	formula = switch action
		when 'SumAll'
			data = "data"
			"_.reduce(_.pluck(#{data},'#{name}'),function(sum, num) {return parseFloat(sum) + parseFloat(num);})"
		when 'AvgAll'
			data = "data"
			"_.reduce(_.pluck(#{data},'#{name}'),function(sum, num) {return parseFloat(sum) + parseFloat(num);}) / _.size(#{data})"
		when 'CountAll'
			data = "data"
			"_.chain(#{data}).countBy('#{name}').size().value()"
		when 'MinAll'
			data = "data"
			"_.chain(#{data}).pluck('#{name}').min().value()"
		when 'MaxAll'
			data = "data"
			"_.chain(#{data}).pluck('#{name}').max().value()"
		when 'Sum'
			data = "gdata"
			"_.reduce(_.pluck(#{data},'#{name}'),function(sum, num) {return parseFloat(sum) + parseFloat(num);})"
		when 'Avg'
			data = "gdata"
			"_.reduce(_.pluck(#{data},'#{name}'),function(sum, num) {return parseFloat(sum) + parseFloat(num);}) / _.size(#{data})"
		when 'Count'
			data = "gdata"
			"_.chain(#{data}).countBy('#{name}').size().value()"
		when 'Min'
			data = "gdata"
			"_.chain(#{data}).pluck('#{name}').min().value()"
		when 'Max'
			data = "gdata"
			"_.chain(#{data}).pluck('#{name}').max().value()"
		else field
	return formula

createKey = (row, fields) ->
	key = ''
	for field in fields
		if key != ''
			key = key + '|' + row[field]
		else
			key = row[field]
	return key

groupBy = (data, gb_fields, formula_fields, all_formula_fields) ->
	return data unless gb_fields.length
	gb      = []
	keys    = []
	gdata   = data
	for counter, row of data
		key = createKey row, gb_fields
		if key not in keys
			keys.push key
			json = {}
			for field in gb_fields
				json[field] = row[field]
			gb.push json
	gb_new = gb
	if _.size(formula_fields)>0
		gb_new = []
		for counter,row of gb
			gdata = _.where data, row
			json  = row
			for row_id, formula_data of formula_fields
				for formula_field_name, formula of formula_data
					# console.log formula, formula_field_name
					parsed = parseFormula formula, all_formula_fields
				# console.log "parsed"
				# console.log parsed
				eval "f=function(data,gdata,row){return #{parsed}};"
				json[formula_field_name] = f(data,gdata,row)
			gb_new.push json
	return gb_new

testGroupBy = () ->
	data = [
		{'first':'Joe',
		'last':'Smith',
		'language':'english',
		'occupation':'programmer',
		'age':45,
		'experience':20},
		{'first':'Salle',
		'last':'Gunner',
		'language':'german',
		'occupation':'programmer',
		'age':22,
		'experience':17},
		{'first':'Sally',
		'last':'Jones',
		'language':'french',
		'occupation':'receptionist',
		'age':36,
		'experience':10},
		{'first':'Janie',
		'last':'Johnson',
		'language':'english',
		'occupation':'factory worker',
		'age':40,
		'experience':22},
		{'first':'Suzie',
		'last':'Smothers',
		'language':'english',
		'occupation':'programmer',
		'age':48,
		'experience':15},
		{'first':'Tom',
		'last':'Jones',
		'language':'french',
		'occupation':'programmer',
		'age':47,
		'experience':12}
	]

	window.data = data
	formula_fields = [
		{'Experience Total':'SumAll.experience'}
		{'Experience':'Sum.experience'}
	]

	gb_data = groupBy data, ['occupation'],formula_fields
	console.log gb_data
	# groupBy data, ['language','occupation']
	return true