load_op_env() {
	set -a
	load_env "$HOME/workspace/quo/backend/dev/start/.env"
	load_env "$HOME/workspace/quo/backend/dev/start/.env.local"
	set +a
}
