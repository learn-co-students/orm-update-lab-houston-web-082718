require_relative "../config/environment.rb"
require 'pry'
class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  attr_accessor :name, :grade, :id

  def initialize(id = nil, name, grade)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    DB[:conn].execute("CREATE TABLE IF NOT EXISTS students (id INTEGER PRIMARY KEY, name TEXT, grade INTEGER)")
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS students")
  end

  def save
    if self.id
      self.update
    else
    DB[:conn].execute("INSERT INTO students (name, grade) VALUES(?, ?)", self.name, self.grade)
    @id = DB[:conn].execute("SELECT id FROM students ORDER BY id DESC LIMIT 1")[0][0]
    end
  end

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
  end

  def self.new_from_db(row)
    student = self.new(nil, nil)
    student.id = row[0]
    student.name = row[1]
    student.grade = row[2]
    student
  end

  def self.find_by_name(name)
    DB[:conn].execute("SELECT * FROM students WHERE name = ?", name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
    DB[:conn].execute("UPDATE students SET id = ?, name = ?, grade = ?", self.id, self.name, self.grade) 
  end

end
