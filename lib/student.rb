require_relative "../config/environment.rb"
require 'pry'


class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  attr_accessor :name, :grade, :id

  def initialize (name, grade)
    @name = name
    @grade = grade
    @id = nil
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        name STRING,
        grade INTEGER
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS students
    SQL

    DB[:conn].execute(sql)
  end

  def save

    if self.id == nil
      sql = <<-SQL
        INSERT INTO students (name, grade) VALUEs (?,?)
      SQL

      DB[:conn].execute(sql,self.name, self.grade)

      get_id = <<-SQL
        SELECT id FROM students WHERE name = ? AND grade = ?
      SQL

      the_id = DB[:conn].execute(get_id, self.name, self.grade)
      self.id = the_id[0][0]
    else
      self.update
    end

  end

  def self.create (name, grade)
    new_student = Student.new(name, grade)
    new_student.save

  end

  def self.new_from_db (array)
    
    new_student = Student.new(array[1], array[2])
    new_student.id = array[0]
    new_student
  end

  def update
    update = <<-SQL
      UPDATE students SET name = ?, grade = ? WHERE id = ?
    SQL
    DB[:conn].execute(update, self.name, self.grade, self.id)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM students WHERE name = ?
    SQL

    new_name = DB[:conn].execute(sql, name)
    new_instance = Student.new_from_db(new_name[0])
    new_instance
  end


end

