require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  attr_accessor :id, :name, :grade

  # has a name and a grade
  # has an id that defaults to `nil` on initialization
  def initialize(id = nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  # creates the students table in the database
  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  # drops the students table from the database
  def self.drop_table
    sql = <<-SQL
    DROP TABLE IF EXISTS students
    SQL

    DB[:conn].execute(sql)
  end

  # saves an instance of the Student class to the database and 
  # then sets the given students `id` attribute
  def save
    if self.id == nil
      sql = <<-SQL
        INSERT INTO students (name, grade) VALUES (?,?)
      SQL

      DB[:conn].execute(sql, self.name, self.grade)

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    
    # updates a record if called on an object that is already persisted
    else
      sql = <<-SQL
        UPDATE students SET name = ?, grade = ? WHERE id = ?
      SQL

      DB[:conn].execute(sql, self.name, self.grade, self.id)
    end
  end

  # creates a student object with name and grade attributes
  def self.create(name, grade)
    sql = <<-SQL
    INSERT INTO students (name, grade) VALUES (?,?)
    SQL

    DB[:conn].execute(sql, name, grade)
  end

  # creates an instance with corresponding attribute values
  def self.new_from_db(row)
    Student.new(row[0], row[1], row[2])
  end

  # returns an instance of student that matches the name from the DB
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM students WHERE name = ? LIMIT 1
    SQL

    self.new_from_db(DB[:conn].execute(sql, name).flatten)
  end

  # updates the record associated with a given instance
  def update
    sql = <<-SQL
      UPDATE students SET name = ?, grade = ? WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

end
