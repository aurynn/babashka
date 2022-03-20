postgres_database_create() {
  postgres.database.create "test_database"
}

postgres_database_alter() {
  requires postgres_database_create
  postgres.user.create "test_user" -p "testpassword"
  postgres.database.create "test_database" -o "test_user"
}

postgres_database_absent() {
  postgres.database.absent "test_database"
}
