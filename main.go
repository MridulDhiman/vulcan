package main

import (
	"fmt"
	"io"
	"log"
	"os"
	"path/filepath"
	"github.com/fatih/color"
)

type ScaffoldConfig struct {
	ProjectName     string
	SourceDirectory string
}



func main() {
	green := color.New(color.FgGreen).SprintFunc()
	red := color.New(color.FgRed).SprintFunc()

	
	if len(os.Args) < 3 {
		fmt.Println(red("Usage: vulcan <project_name> <source_template_directory>"))
		os.Exit(1)
	}

	cwd, errr:= os.Executable() // it will give /asauchi/bin/vulcan.exe
	if errr != nil {
		fmt.Println(red("Could not get executable's working directory"));
		os.Exit(1)
	}
	
	config := ScaffoldConfig{
		ProjectName:     os.Args[1],
		SourceDirectory: filepath.Join(cwd, "../..", os.Args[2]),
	}

	err := scaffoldProject(config)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println(green("✓ Terraform project scaffolded successfully"))
}

func scaffoldProject(config ScaffoldConfig) error {
	// Create new project directory
	projectDir := filepath.Join(".", config.ProjectName)
	err := os.MkdirAll(projectDir, os.ModePerm)
	if err != nil {
		return err
	}

	// Copy all files from source directory to new project
	err = filepath.Walk(config.SourceDirectory, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		// Skip source directory itself
		if path == config.SourceDirectory {
			return nil
		}

		// Compute destination path
		relativePath, err := filepath.Rel(config.SourceDirectory, path)
		if err != nil {
			return err
		}
		destPath := filepath.Join(projectDir, relativePath)

		// If it's a directory, create it
		if info.IsDir() {
			return os.MkdirAll(destPath, os.ModePerm)
		}

		// Copy file
		return copyFile(path, destPath)
	})

	return err
}

func copyFile(sourcePath, destPath string) error {
	// Open source file
	sourceFile, err := os.Open(sourcePath)
	if err != nil {
		return err
	}
	defer sourceFile.Close()

	// Create destination file
	destFile, err := os.Create(destPath)
	if err != nil {
		return err
	}
	defer destFile.Close()

	// Copy file contents
	_, err = io.Copy(destFile, sourceFile)
	return err
}