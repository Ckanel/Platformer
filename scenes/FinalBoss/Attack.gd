extends State

func enter():
	super.enter()
	combo()
	
func attack(move = "1"):
	animation_player.play("attack_" + move)
	await animation_player.animation_finished
func combo():
	var move_set = ["1","1","2"]
	for i in move_set:
		await attack(i)
	combo()

func damage():
	get_parent().get_parent().get_parent().find_child("MainAvatar").take_damage(1)

func transition():
	if owner.direction.length() >40 :
		get_parent().change_state("Follow")


