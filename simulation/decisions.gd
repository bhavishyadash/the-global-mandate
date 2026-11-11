extends RefCounted

# Public command IDs and exact argument shapes. Values are validated before
# domain methods run; a failed vote may still produce an explanatory event.
const SCHEMA := {
	"set_income_tax": {"rate": "number"},
	"set_additional_tax": {"kind": "string", "rate": "number"},
	"set_total_spending": {"amount": "number"},
	"set_category_spending": {"category": "string", "amount": "number"},
	"vote_procurement": {}, "repeal_procurement": {},
	"vote_healthcare": {"funding": "number"}, "repeal_healthcare": {},
	"set_healthcare_appropriation": {"fraction": "number"},
	"issue_directive": {"kind": "string"}, "revoke_directive": {},
	"start_talks": {"partner": "string", "proposal": "string"},
	"cancel_talks": {}, "end_cooperation": {"partner": "string"},
}
const MESSAGES := {
	"set_income_tax": ["Income tax updated.", "Income tax change is unavailable."],
	"set_additional_tax": ["Tax updated.", "Tax change is unavailable."],
	"set_total_spending": ["Total spending updated.", "Total spending is outside the allowed range."],
	"set_category_spending": ["Category spending updated.", "Category or amount is unavailable."],
	"vote_procurement": ["Procurement vote passed.", "Procurement vote failed or the policy is already active."],
	"repeal_procurement": ["Procurement repeal passed.", "Repeal failed or the policy is not active."],
	"vote_healthcare": ["Healthcare proposal passed.", "Healthcare proposal failed, is unchanged, or is invalid."],
	"repeal_healthcare": ["Healthcare repeal passed.", "Healthcare repeal failed or the policy is not active."],
	"set_healthcare_appropriation": ["Healthcare appropriation updated.", "Healthcare appropriation is unavailable."],
	"issue_directive": ["Directive issued.", "Directive is unavailable or another directive is active."],
	"revoke_directive": ["Directive revoked.", "No active directive to revoke."],
	"start_talks": ["Diplomatic talks opened.", "Talks unavailable: check the partner, proposal, active talks and cooldown."],
	"cancel_talks": ["Diplomatic talks cancelled.", "No talks are active."],
	"end_cooperation": ["Cooperation ended; relations reduced.", "No cooperation agreement with the selected partner."],
}

static func execute(world: Variant, request: Variant) -> Dictionary:
	if world == null or not request is Dictionary or not request.get("id") is String or not request.get("args") is Dictionary or request.size() != 2:
		return _result(false, "invalid_request", "Decision request must contain an ID and arguments.")
	var id: String = request.id
	if not SCHEMA.has(id):
		return _result(false, "unknown_decision", "Unknown decision.")
	var args: Dictionary = request.args
	var expected: Dictionary = SCHEMA[id]
	if args.size() != expected.size():
		return _result(false, "invalid_arguments", "Decision arguments are incomplete or unexpected.")
	for key in expected:
		if not args.has(key):
			return _result(false, "invalid_arguments", "Decision arguments are incomplete or unexpected.")
		if expected[key] == "string" and not args[key] is String:
			return _result(false, "invalid_arguments", "Decision argument has the wrong type.")
		if expected[key] == "number" and (not (args[key] is int or args[key] is float) or not is_finite(float(args[key]))):
			return _result(false, "invalid_arguments", "Decision amount must be a finite number.")
	var accepted := false
	match id:
		"set_income_tax": accepted = world.set_income_tax(float(args.rate))
		"set_additional_tax": accepted = world.set_additional_tax(args.kind, float(args.rate))
		"set_total_spending": accepted = world.set_annual_spending(float(args.amount))
		"set_category_spending": accepted = world.set_category_spending(args.category, float(args.amount))
		"vote_procurement": accepted = world.vote_procurement()
		"repeal_procurement": accepted = world.vote_procurement_repeal()
		"vote_healthcare": accepted = world.vote_healthcare(float(args.funding))
		"repeal_healthcare": accepted = world.repeal_healthcare()
		"set_healthcare_appropriation": accepted = world.set_healthcare_appropriation(float(args.fraction))
		"issue_directive": accepted = world.issue_directive(args.kind)
		"revoke_directive": accepted = world.revoke_directive()
		"start_talks": accepted = world.start_diplomatic_talks(args.partner, args.proposal)
		"cancel_talks": accepted = world.cancel_diplomatic_talks()
		"end_cooperation": accepted = world.end_cooperation(args.partner)
	return _result(accepted, "accepted" if accepted else "unavailable", MESSAGES[id][0 if accepted else 1])

static func _result(ok: bool, code: String, message: String) -> Dictionary:
	return {"ok": ok, "code": code, "message": message}
