#include <iostream>
#include <vector>
#include <string>
#include <iomanip>
#include <chrono>
#include <fstream>
using namespace std;
using namespace std::chrono;

struct Student {
    string name;
    int rollNo;
    float marks;
};

// Utility function to display student data in tabular format
void displayStudents(const vector<Student>& students) {
    cout << left << setw(15) << "Name" 
         << setw(10) << "Roll No" 
         << setw(10) << "Marks" << endl;
    cout << string(35, '-') << endl;
    for (const auto& s : students) {
        cout << left << setw(15) << s.name 
             << setw(10) << s.rollNo 
             << setw(10) << s.marks << endl;
    }
    cout << endl;
}

// --------------------- Sorting Algorithms ---------------------
void bubbleSort(vector<Student>& arr, int option) {
    int n = arr.size();
    for (int i = 0; i < n-1; i++) {
        for (int j = 0; j < n-i-1; j++) {
            bool condition = false;
            if (option == 1) condition = arr[j].marks < arr[j+1].marks;
            else if (option == 2) condition = arr[j].name > arr[j+1].name;
            else if (option == 3) condition = arr[j].rollNo > arr[j+1].rollNo;
            
            if (condition) swap(arr[j], arr[j+1]);
        }
    }
}

int partition(vector<Student>& arr, int low, int high, int option) {
    Student pivot = arr[high];
    int i = low - 1;

    for (int j = low; j < high; j++) {
        bool condition = false;
        if (option == 1) condition = arr[j].marks > pivot.marks;
        else if (option == 2) condition = arr[j].name < pivot.name;
        else if (option == 3) condition = arr[j].rollNo < pivot.rollNo;

        if (condition) {
            i++;
            swap(arr[i], arr[j]);
        }
    }
    swap(arr[i+1], arr[high]);
    return i + 1;
}

void quickSort(vector<Student>& arr, int low, int high, int option) {
    if (low < high) {
        int pi = partition(arr, low, high, option);
        quickSort(arr, low, pi - 1, option);
        quickSort(arr, pi + 1, high, option);
    }
}

void merge(vector<Student>& arr, int left, int mid, int right, int option) {
    int n1 = mid - left + 1;
    int n2 = right - mid;
    vector<Student> L(n1), R(n2);

    for (int i = 0; i < n1; i++) L[i] = arr[left + i];
    for (int j = 0; j < n2; j++) R[j] = arr[mid + 1 + j];

    int i = 0, j = 0, k = left;
    while (i < n1 && j < n2) {
        bool condition = false;
        if (option == 1) condition = L[i].marks >= R[j].marks;
        else if (option == 2) condition = L[i].name <= R[j].name;
        else if (option == 3) condition = L[i].rollNo <= R[j].rollNo;

        if (condition) arr[k++] = L[i++];
        else arr[k++] = R[j++];
    }
    while (i < n1) arr[k++] = L[i++];
    while (j < n2) arr[k++] = R[j++];
}

void mergeSort(vector<Student>& arr, int left, int right, int option) {
    if (left < right) {
        int mid = left + (right - left) / 2;
        mergeSort(arr, left, mid, option);
        mergeSort(arr, mid + 1, right, option);
        merge(arr, left, mid, right, option);
    }
}

// --------------------- File Handling ---------------------
void saveToFile(const vector<Student>& students, const string& filename) {
    ofstream fout(filename);
    for (auto& s : students)
        fout << s.name << "," << s.rollNo << "," << s.marks << "\n";
    fout.close();
    cout << "Data saved to " << filename << endl;
}

vector<Student> loadFromFile(const string& filename) {
    vector<Student> students;
    ifstream fin(filename);
    string name;
    int roll;
    float marks;
    char comma;
    while (fin >> ws && getline(fin, name, ',')) {
        fin >> roll >> comma >> marks;
        students.push_back({name, roll, marks});
    }
    fin.close();
    cout << "Data loaded from " << filename << endl;
    return students;
}

// --------------------- Binary Search ---------------------
int binarySearchByName(const vector<Student>& students, string name) {
    int low = 0, high = students.size() - 1;
    while (low <= high) {
        int mid = (low + high) / 2;
        if (students[mid].name == name)
            return mid;
        else if (students[mid].name < name)
            low = mid + 1;
        else
            high = mid - 1;
    }
    return -1;
}

// --------------------- Main Program ---------------------
int main() {
    vector<Student> students;
    int choice;

    do {
        cout << "\n=== SMART STUDENT RANK MANAGER ===\n";
        cout << "1. Add Student Data\n";
        cout << "2. Display Students\n";
        cout << "3. Sort Students\n";
        cout << "4. Search Student by Name\n";
        cout << "5. Save to File\n";
        cout << "6. Load from File\n";
        cout << "0. Exit\n";
        cout << "Enter your choice: ";
        cin >> choice;

        switch(choice) {
            case 1: {
                Student s;
                cout << "Enter Name: "; cin >> s.name;
                cout << "Enter Roll No: "; cin >> s.rollNo;
                cout << "Enter Marks: "; cin >> s.marks;
                students.push_back(s);
                break;
            }
            case 2: {
                if (students.empty()) cout << "No data available.\n";
                else displayStudents(students);
                break;
            }
            case 3: {
                if (students.empty()) { cout << "No data to sort.\n"; break; }

                cout << "Sort by: 1.Marks  2.Name  3.Roll No\nChoice: ";
                int option; cin >> option;

                cout << "Choose Algorithm: 1.Bubble  2.Quick  3.Merge\nChoice: ";
                int algo; cin >> algo;

                vector<Student> sorted = students;

                auto start = high_resolution_clock::now();

                if (algo == 1) bubbleSort(sorted, option);
                else if (algo == 2) quickSort(sorted, 0, sorted.size()-1, option);
                else if (algo == 3) mergeSort(sorted, 0, sorted.size()-1, option);

                auto stop = high_resolution_clock::now();
                auto duration = duration_cast<microseconds>(stop - start);
                
                cout << "\n--- Before Sorting ---\n";
                displayStudents(students);
                cout << "--- After Sorting ---\n";
                displayStudents(sorted);
                cout << "Time Taken: " << duration.count() << " microseconds\n";
                students = sorted; // Update with sorted data
                break;
            }
            case 4: {
                if (students.empty()) { cout << "No data available.\n"; break; }
                cout << "Enter name to search: ";
                string name; cin >> name;
                int index = binarySearchByName(students, name);
                if (index != -1)
                    cout << "Found: " << students[index].name << ", Roll No: "
                         << students[index].rollNo << ", Marks: " << students[index].marks << endl;
                else
                    cout << "Student not found!\n";
                break;
            }
            case 5: saveToFile(students, "students.txt"); break;
            case 6: students = loadFromFile("students.txt"); break;
            case 0: cout << "Exiting...\n"; break;
            default: cout << "Invalid choice.\n";
        }
    } while (choice != 0);

    return 0;
}