#include <iostream>
#include <string>
#include <windows.h>
#include <stdlib.h>
#include <conio.h>
#include <fstream>
#include <algorithm>
#include <vector>
#include <time.h>
#include <sstream>
using namespace std;

HANDLE hout;
int button_num, button_focus, getstring, Big_num, glo_pos, gamestart;
vector<string> altext, Blockname;
string **Bigblock, Filename, nowpos;
int nowline, nowcol, lines, nowline_cols, upline, oncoding, checkcount, checkcoding;
vector<string> fulltext, checktext;

void draw_form(short x, short y, int width, int height, string horizontal, int color);
string *Depart(string text, char ch, int *back_count = nullptr)
{
    string *back;
    int count = std::count(text.begin(), text.end(), ch), pos = 0, new_pos;
    back = new string[count + 1];
    for (int i = 0; i < count; i++)
    {
        new_pos = text.find(ch, pos);
        back[i] = text.substr(pos, new_pos - pos);
        pos = new_pos + 1;
    }
    back[count] = text.substr(pos);
    if (back_count != nullptr)
        *back_count = count;
    return back;
}
void setCur(short x, short y)
{
    COORD pos{x, y};
    SetConsoleCursorPosition(hout, pos);
}
class Button
{
public:
    short x;
    short y;
    int width;
    int height;
    string text;
    Button()
    {
        x = 0;
        y = 0;
        width = 0;
        height = 0;
        text = "";
    };
    Button(short x, short y, int width, int height, string text)
    {
        this->x = x;
        this->y = y;
        this->width = width;
        this->height = height;
        this->text = " " + text;
    };
    void change(short x, short y, int width, int height, string text)
    {
        this->x = x;
        this->y = y;
        this->width = width;
        this->height = height;
        this->text = " " + text;
    };
    void create()
    {
        draw_form(x, y, width, height, "", 0xFFFF);
        setCur((short)(x + 1), (short)(y + 1));
        if (text.find(':') != -1)
        {
            string *temp;
            temp = Depart(text, ':');
            cout << temp[0].substr(0, width);
        }
        else
            cout << text.substr(0, width);
    };
    void highlight()
    {
        draw_form(x, y, width, height, "", FOREGROUND_RED);
        setCur((short)(x + 1), (short)(y + 1));
        if (text.find(':') != -1)
        {
            string *temp;
            temp = Depart(text, ':');
            cout << temp[0].substr(0, width);
        }
        else
            cout << text.substr(0, width);
    };
    void operator=(const Button target)
    {
        x = target.x;
        y = target.y;
        width = target.width;
        height = target.height;
        text = target.text;
    };
    void destroy()
    {
        setCur(x, y);
        int i, j;
        for (i = 0; i < height + 2; i++)
        {
            setCur(x, y + i);
            for (j = 0; j < width + 2; j++)
            {
                cout << " ";
            }
        }
    };
};

class Text
{
public:
    short x;
    short y;
    int width;
    int height;
    int direction;
    string text;
    Text()
    {
        x = 0;
        y = 0;
        width = 0;
        height = 0;
        text = "";
        direction = 0;
    };
    Text(short x, short y, int width, string text, int direction = 0)
    {
        this->text = " " + text;
        this->width = width;
        int line = this->text.length() / width;
        this->height = line + 2;
        if (direction == 0)
            this->x = x;
        else if (direction == 1)
        {
            if (line == 0)
                this->x = x - this->text.length() - 1;
            else
                this->x = x - width - 1;
        }
        else
        {
            if (line == 0)
                this->x = x - this->text.length() / 2;
            else
                this->x = x - width / 2;
        }
        this->y = y - this->height;
    };
    void change(short x, short y, int width, string text, int direction = 0)
    {
        this->text = " " + text;
        this->width = width;
        this->direction = direction;
        int line = this->text.length() / width;
        this->height = line + 2;
        if (direction == 0)
            this->x = x;
        else if (direction == 1)
        {
            if (line == 0)
                this->x = x - this->text.length() - 1;
            else
                this->x = x - width - 1;
        }
        else
        {
            if (line == 0)
                this->x = x - this->text.length() / 2;
            else
                this->x = x - width / 2;
        }
        this->y = y - this->height;
    };
    void create()
    {
        int line = text.length() / width;
        if (direction != 2)
        {
            if (line == 0)
            {
                if (direction == 0)
                {
                    setCur(x, y);
                    cout << "│" << text;
                    setCur(x, y + 1);
                    cout << "└";
                    for (int i = 0; i < text.length(); i++)
                        cout << "─";
                }
                else
                {
                    setCur(x, y);
                    cout << text << "│";
                    setCur(x, y + 1);
                    for (int i = 0; i < text.length(); i++)
                        cout << "─";
                    cout << "┘";
                }
            }
            else
            {
                for (int i = 0; i <= line; i++)
                {
                    setCur(x, y + i);
                    if (direction == 0)
                    {
                        cout << "│" << text.substr(i * width, width);
                    }
                    else
                    {
                        cout << text.substr(i * width, width);
                        if (i == line)
                            setCur(x + width, y + i);
                        cout << "│";
                    }
                }
                setCur(x, y + line + 1);
                if (direction == 0)
                    cout << "└────────────────────────────────────────";
                else
                    cout << "────────────────────────────────────────┘";
            }
        }
        else
        {
            if (line == 0)
            {
                setCur(x, y);
                cout << text;
                setCur(x, y + 1);
                for (int i = 0; i < text.length(); i++)
                    cout << "─";
            }
            else
            {
                for (int i = 0; i <= line; i++)
                {
                    if (i != line)
                        setCur(x, y + i);
                    else
                        setCur(x + (width - text.substr(i * width, width).length()) / 2, y + i);
                    cout << text.substr(i * width, width);
                }
                setCur(x, y + line + 1);
                cout << "────────────────────────────────────────";
            }
        }
    };
};

Button *button;

void draw_form(short x, short y, int width, int height, string horizontal, int color)
{
    SetConsoleTextAttribute(hout, color);
    COORD pos{x, y};
    int i, j;
    SetConsoleCursorPosition(hout, pos);
    cout << "┌";
    for (i = 0; i < width; i++)
    {
        cout << "─";
    }
    cout << "┐";
    for (i = 0; i < height; i++)
    {
        pos.Y++;
        SetConsoleCursorPosition(hout, pos);
        cout << "│";
    }
    pos.Y = y;
    pos.X += width + 1;
    for (i = 0; i < height; i++)
    {
        pos.Y++;
        SetConsoleCursorPosition(hout, pos);
        cout << "│";
    }
    pos.X = x;
    SetConsoleCursorPosition(hout, pos);
    cout << "└";
    for (i = 0; i < width; i++)
    {
        cout << "─";
    }
    cout << "┘";
    int count = horizontal.length() / 2;
    for (i = 0; i < count; i++)
    {
        pos.X = x;
        pos.Y = y + stoi(horizontal.substr(i * 2, 2));
        SetConsoleCursorPosition(hout, pos);
        cout << "├";
        for (j = 0; j < width; j++)
        {
            cout << "─";
        }
        cout << "┤";
    }
    pos.X = x;
    pos.Y = y + height + 1;
    SetConsoleCursorPosition(hout, pos);
    SetConsoleTextAttribute(hout, 15);
}

bool Console_close(DWORD dwCtrlType)
{
    if (CTRL_CLOSE_EVENT == dwCtrlType)
    {
        if (gamestart == 1)
        {
            ofstream file(Filename, ios::in | ios::ate);
            if (file)
            {
                file.seekp(-7, ios::end);
                file.write(Blockname[glo_pos].c_str(), 3);
                file.write(nowpos.c_str(), 3);
                file.close();
            }
        }
        else if (oncoding == 1)
        {
            ofstream file(Filename, ios::out);
            if (file)
            {
                for (int i = 0; i < fulltext.size() - 1; i++)
                {
                    file << fulltext[i];
                    file << '\n';
                }
                file << fulltext[lines - 1];
                file.close();
            }
        }
    }
    return true;
}

void focusNext()
{
    Button temp_ = button[button_focus];
    temp_.create();
    if ((button_focus++) >= button_num - 1)
        button_focus = 0;
    temp_ = button[button_focus];
    temp_.highlight();
}

void Inin()
{
    srand(time(NULL));
    system("mode con cols=63 lines=42");
    hout = GetStdHandle(STD_OUTPUT_HANDLE);
    SetConsoleTitle("Story");
    draw_form(0, 0, 60, 38, "25", 15);
    Text tip(30, 5, 40, "tap key -- change button", 2);
    tip.create();
    tip.change(30, 7, 40, "enter key -- select", 2);
    tip.create();
    tip.change(30, 9, 40, "esc key -- leave", 2);
    tip.create();
    tip.change(30, 11, 40, "F5 key -- check", 2);
    tip.create();
    tip.change(30, 13, 40, "F9 key -- save", 2);
    tip.create();
    tip.change(30, 15, 40, "F10 key -- auto repair the code", 2);
    tip.create();
    Button temp(20, 26, 20, 2, "     Open file");
    temp.create();
    temp.highlight();
    SetConsoleCtrlHandler((PHANDLER_ROUTINE)Console_close, true);
    button_num = 4;
    button_focus = 0;
    button = new Button[button_num];
    if (button == NULL)
    {
        OutputDebugString("Error");
        return;
    }
    button[0] = temp;
    temp.change(20, 29, 20, 2, "    Create New");
    temp.create();
    button[1] = temp;
    temp.change(20, 32, 20, 2, "    Open sourse");
    temp.create();
    button[2] = temp;
    temp.change(20, 35, 20, 2, "        Exit");
    temp.create();
    button[3] = temp;
    getstring = 0;
    altext.clear();
    Blockname.clear();
    glo_pos = 0;
    gamestart = 0;
    oncoding = 0;
    checkcoding = 0;
}

int Getcount(string filename, char ch)
{
    ifstream file(filename, ios::in);
    if (file.is_open() == false)
        return -1;
    int i = 0;
    string str;
    while (!file.eof())
    {
        file >> str;
        i += count(str.begin(), str.end(), ch);
    }
    file.close();
    return i;
}

int ReadSourse(string *back)
{
    ifstream file(Filename, ios::in);
    string str, *Smallblock, str_temp;
    char *buffer;
    int small_num;
    system("cls");
    draw_form(0, 0, 60, 35, "25", 15);
    Button temp(20, 10, 20, 2, "       Loading...");
    temp.create();
    Sleep(100);
    if (file.is_open() == false)
    {
        system("cls");
        draw_form(0, 0, 60, 35, "25", 4);
        temp.change(20, 10, 20, 2, "       Error!!!");
        temp.create();
        return -1;
    }
    file >> str;
    SetConsoleTitle(str.substr(6, str.find(')', 6) - 6).c_str());
    Big_num = Getcount(Filename, '[');
    Bigblock = new string *[Big_num];
    file.seekg(-8, ios::end);
    char buffer2[8];
    file.read(buffer2, 7);
    *back = buffer2;
    file.seekg(0, ios::beg);
    str.clear();
    while (!file.eof())
    {
        char ch;
        file >> str_temp;
        ch = file.get();
        str += str_temp;
        if (ch != '\n')
            str += ch;
    }
    file.close();
    int pos = 0, new_pos;
    for (int i = 0; i < Big_num; i++)
    {
        pos = str.find('[', pos);
        Blockname.push_back(str.substr(pos - 3, 3));
        new_pos = str.find(']', pos);
        str_temp = str.substr(pos + 1, new_pos - pos - 1);
        small_num = count(str_temp.begin(), str_temp.end(), '|') / 2;
        Smallblock = new string[small_num];
        int pos_ = 0, new_pos_;
        for (int j = 0; j < small_num; j++)
        {
            pos_ = str_temp.find('{', pos_);
            new_pos_ = str_temp.find('}', pos_);
            Smallblock[j] = str_temp.substr(pos_ + 1, new_pos_ - pos_ - 1);
            pos_ = new_pos_;
        }
        Bigblock[i] = Smallblock;
        pos = new_pos;
    }
    return 0;
}

string Findtext(string head)
{
    if (head.length() == 3)
    {
        return Bigblock[glo_pos][stoi(head) - 1];
    }
    else if (head.length() == 6)
    {
        string str = head.substr(0, 3);
        glo_pos = find(Blockname.begin(), Blockname.end(), str) - Blockname.begin();
        return Bigblock[glo_pos][stoi(head.substr(3, 3)) - 1];
    }
    else
        return "";
}

void Draw()
{
    for (int i = 0; i < 24; i++)
    {
        setCur(1, 1 + i);
        cout << "                                                            ";
    }
    int num = altext.size(), top = 25, i = 0;
    Text temp;
    string *temp_text;
    do
    {
        temp_text = Depart(altext[i], ',');
        if (temp_text[0] == "0")
            temp.change(1, top, 39, temp_text[1], 0);
        if (temp_text[0] == "1")
            temp.change(60, top, 39, temp_text[1], 1);
        if (temp_text[0] == "2")
            temp.change(30, top, 38, temp_text[1], 2);
        temp.create();
        top -= temp.height;
        i++;
        if (i < num)
        {
            temp_text = Depart(altext[i], ',');
            temp.change(0, top, 38, temp_text[1], 0);
        }
    } while (i < num && temp.y >= 1);
}

void choose(string code = "#0xA001")
{
    getstring = 1;
    code = code.substr(1);
    string *_temp = Depart(Findtext(code), '|'), *_temp2;
    int n;
    if (code.length() == 3)
        nowpos = code;
    else
        nowpos = code.substr(3, 3);
    int count;
    if (_temp[0] != "NULL")
    {
        _temp2 = Depart(_temp[0], '/', &n);
        for (int i = 0; i < n + 1; i++)
        {
            Sleep(500);
            altext.insert(altext.begin(), "2," + _temp2[i]);
            Draw();
        }
    }
    if (_temp[1] != "NULL")
    {
        _temp2 = Depart(_temp[1], '/', &n);
        for (int i = 0; i < n + 1; i++)
        {
            Sleep(500);
            altext.insert(altext.begin(), "0," + _temp2[i]);
            Draw();
        }
    }
    _temp = Depart(_temp[2], ',', &count);
    button_num = count + 1;
    delete[] button;
    button = new Button[4];
    button[0].y = 27;
    button[1].y = 30;
    button[2].y = 33;
    button[3].y = 36;
    for (int i = 0; i < 4; i++)
    {
        button[i].x = 10;
        button[i].width = 40;
        button[i].height = 2;
        if (i < button_num)
            button[i].text = _temp[i];
        else
            button[i].text = "";
    }
    button[0].destroy();
    button[1].destroy();
    button[2].destroy();
    button[3].destroy();
    button[0].create();
    button[1].create();
    button[2].create();
    button[3].create();
    button_focus = 0;
    button[0].highlight();
    getstring = 0;
}

int Findall(string str, int n, int pos_u = 0, int *line_ = nullptr, int *index_ = nullptr)
{
    int back = 0;
    int index = 0;
    int pos;
    for (int i = 0; i < n; i++)
    {
        index += fulltext[i].length();
    }
    for (int i = n; i < fulltext.size(); i++)
    {
        pos = -1;
        string s = fulltext[i];
        while ((pos = fulltext[i].find(str, pos + 1)) != -1)
        {
            if ((pos >= pos_u && i == n) || i > n)
            {
                index += pos;
                back = 1;
                if (line_ != nullptr)
                    *line_ = i + 1;
                if (index_ != nullptr)
                    *index_ = pos;
                break;
            }
        }
        if (back == 1)
            break;
        index += fulltext[i].length();
    }
    if (back == 0)
        return -1;
    else
        return index;
}

int rFindall(string str, int n, int pos_u = 0, int *line_ = nullptr, int *index_ = nullptr)
{
    int back = 0;
    int index = 0;
    int pos;
    for (int i = 0; i <= n; i++)
    {
        index += fulltext[i].length();
    }
    for (int i = n; i >= 0; i--)
    {
        pos = fulltext[i].length();
        index -= pos;
        while ((pos = fulltext[i].rfind(str, pos - 1)) != -1)
        {
            if ((pos <= pos_u && i == n) || i < n)
            {
                index += pos;
                back = 1;
                if (line_ != nullptr)
                    *line_ = i + 1;
                if (index_ != nullptr)
                    *index_ = pos;
                break;
            }
        }
        if (back == 1)
            break;
    }
    if (back == 0)
        return -1;
    else
        return index;
}

string itos(int number)
{
    stringstream temp;
    temp << number;
    return temp.str();
}

void autoRepair()
{
    int i, pos1, pos2, pos3, pos4, pos5, _line, _index, __line, __index, ___line, ___index, count;
    string temp, temp_, re;
    for (i = 0; i < fulltext.size(); i++)
    {
        pos1 = -1;
        string s = fulltext[i];
        while ((pos1 = s.find(':', pos1 + 1)) != -1)
        {
            if (s.length() - pos1 - 1 > 1)
            {
                if (s[pos1 + 1] != '#' && s[pos1 + 1] != 'e' && s[pos1 + 1] != 'r')
                {
                    fulltext[i].insert(fulltext[i].begin() + pos1 + 1, '#');
                    s.insert(s.begin() + pos1 + 1, '#');
                    pos1++;
                }
            }
        }
    }
    pos1 = 0;
    _line = 0;
    _index = 0;
    while ((pos1 = Findall("[", _line, _index + 1, &_line, &_index)) != -1)
    {
        if (_index == 3)
        {
            temp = fulltext[_line - 1].substr(0, 3);
            pos2 = Findall("]", _line - 1, _index);
            count = 1;
            __line = _line;
            __index = _index;
            while ((pos3 = Findall("{", __line - 1, __index + 1, &__line, &__index)) != -1 && count <= 999)
            {
                if (pos3 < pos2)
                {
                    if (__index == 3)
                    {
                        temp_ = fulltext[__line - 1].substr(0, 3);
                        if (stoi(temp_) == count)
                        {
                            count++;
                            continue;
                        }
                        re = itos(count);
                        fulltext[__line - 1].replace(3 - re.length(), re.length(), re.c_str());
                        ___line = _line;
                        ___index = _index;
                        while ((pos4 = Findall('#' + temp_, ___line - 1, ___index + 1, &___line, &___index)) != -1)
                        {
                            if (pos4 < pos2)
                                fulltext[___line - 1].replace(___index + 4 - re.length(), re.length(), re.c_str());
                            else
                                break;
                        }
                        ___line = 1;
                        ___index = 0;
                        while ((pos4 = Findall('#' + temp + temp_, ___line - 1, ___index + 1, &___line, &___index)) != -1)
                        {
                            if (pos4 < pos1 || pos4 > pos2)
                                fulltext[___line - 1].replace(___index + 7 - re.length(), re.length(), re.c_str());
                        }
                    }
                }
                count++;
            }
        }
    }
}

void Check(string text, int line)
{
    int pos1, pos2, pos3, pos4, pos5, length;
    length = text.length();
    pos1 = 0;
    char ch;
    string temp;
    while (pos1 < length)
    {
        ch = text.c_str()[pos1];
        if (ch == '(')
        {
            pos2 = Findall(")", line, pos1 + 1);
            pos3 = Findall("(", line, pos1 + 1);
            if (pos2 == -1 || (pos3 < pos2 && pos3 != -1))
                checktext.push_back("line " + itos(line + 1) + " column " + itos(pos1 + 1) + ":\'(\' is imcomplete.");
            pos1 += 1;
        }
        else if (ch == '[')
        {
            pos2 = Findall("]", line, pos1 + 1);
            pos3 = Findall("[", line, pos1 + 1);
            if (pos2 == -1 || (pos3 < pos2 && pos3 != -1))
                checktext.push_back("line " + itos(line + 1) + " column " + itos(pos1 + 1) + ":\'[\' is imcomplete.");
            pos1 += 1;
        }
        else if (ch == '{')
        {
            pos2 = Findall("}", line, pos1 + 1);
            pos3 = Findall("{", line, pos1 + 1);
            if (pos2 == -1 || (pos3 < pos2 && pos3 != -1))
                checktext.push_back("line " + itos(line + 1) + " column " + itos(pos1 + 1) + ":\'{\' is imcomplete.");
            pos1 += 1;
        }
        else if (ch == '#')
        {
            pos2 = text.find('}', pos1);
            pos3 = text.find(',', pos1);
            pos4 = text.find('/', pos1);
            pos5 = text.find(')', pos1);
            vector<int> compare;
            compare.clear();
            if (pos2 != -1)
                compare.push_back(pos2);
            if (pos3 != -1)
                compare.push_back(pos3);
            if (pos4 != -1)
                compare.push_back(pos4);
            if (pos5 != -1)
                compare.push_back(pos5);
            if (compare.size() == 0)
                goto NORMAL;
            else
            {
                pos2 = compare[0];
                for (int i = 1; i < compare.size(); i++)
                {
                    if (compare[i] < pos2)
                        pos2 = compare[i];
                }
                temp = text.substr(pos1, pos2 - pos1);
            }
            compare.clear();
            string temp_ = temp.substr(1);
            if (temp_.length() == 3)
            {
                int line_, index_;
                pos2 = Findall("]", line, pos1, &line_, &index_);
                pos2 = rFindall(temp_ + '{', line_ - 1, index_);
                pos3 = rFindall("[", line, pos1, &line_, &index_);
                pos3 = Findall(temp_ + '{', line_ - 1, index_);
                if (pos2 == -1 || pos3 == -1)
                    checktext.push_back("line " + itos(line + 1) + " column " + itos(pos1 + 1) + ":the target(" + temp_ + ") is not existing.");
                pos1 += temp.length();
            }
            else if (temp_.length() == 6)
            {
                int line_, index_, line__, index__;
                pos2 = Findall(temp_.substr(0, 3) + '[', 0, 0, &line_, &index_);
                if (pos2 == -1)
                    checktext.push_back("line " + itos(line + 1) + " column " + itos(pos1 + 1) + ":the target(" + temp_ + ") is not existing.");
                else
                {
                    pos3 = Findall("[", line_ - 1, index_, &line__, &index__);
                    pos3 = Findall(temp_.substr(3, 3) + '{', line__ - 1, index__);
                    pos4 = Findall("]", line_ - 1, pos1, &line__, &index__);
                    pos4 = rFindall(temp_.substr(3, 3) + '{', line__ - 1, index__);
                    if (pos3 != -1 && pos4 != -1 && pos3 == pos4)
                        ;
                    else
                        checktext.push_back("line " + itos(line + 1) + " column " + itos(pos1 + 1) + ":the target(" + temp_ + ") is not existing.");
                }
                pos1 += temp.length();
            }
            else
            {
                pos1 += 1;
            }
        }
        else if (ch == ':')
        {
            if (text.length() - pos1 >= 6)
            {
                temp = text.substr(pos1 + 1, 6);
                if (temp.compare("exit()") == 0)
                {
                    pos1 += 5;
                    continue;
                }
            }
            if (text.length() - pos1 >= 4)
            {
                if (text.substr(pos1 + 1, 4).compare("ran(") == 0)
                {
                    int _index, _line;
                    pos1 += 4;
                    pos2 = Findall(")", line, pos1, &_line, &_index);
                    if (pos2 != -1)
                    {
                        pos2 = rFindall("#", _line - 1, _index, &_line, &_index);
                        if (pos2 == -1 || (_index < pos1 && _line - 1 == line) || _line - 1 < line)
                            checktext.push_back("line " + itos(line + 1) + " column " + itos(pos1 + 1) + ":ran() missing the #.");
                    }
                    continue;
                }
            }
            if (text.length() - pos1 >= 1)
            {
                temp = text.substr(pos1 + 1, 1);
                if (temp != "#")
                    checktext.push_back("line " + itos(line + 1) + " column " + itos(pos1 + 1) + ":missing the #.");
            }
            pos1 += 1;
        }
        else
        {
        NORMAL:
            pos1 += 1;
        }
    }
}

void Colorit(string text, int line)
{
    int pos1, pos2, pos3, pos4, pos5, length;
    length = text.length();
    pos1 = 0;
    char ch;
    string temp;
    while (pos1 < length)
    {
        ch = text.c_str()[pos1];
        if (ch == 'B')
        {
            if ((text.length() - pos1) >= 6)
            {
                temp = text.substr(pos1, 6);
                if (temp.compare("Begin(") == 0)
                {
                    SetConsoleTextAttribute(hout, 0xE);
                    cout << "Begin";
                    pos1 += 5;
                }
                else
                    goto NORMAL;
            }
            else
                goto NORMAL;
        }
        else if (ch == 'E')
        {
            if (text.length() - pos1 >= 4)
            {
                temp = text.substr(pos1, 4);
                if (temp.compare("End(") == 0)
                {
                    SetConsoleTextAttribute(hout, 0xE);
                    cout << "End";
                    pos1 += 3;
                }
                else
                    goto NORMAL;
            }
            else
                goto NORMAL;
        }
        else if (ch == 'N')
        {
            if (text.length() - pos1 >= 4)
            {
                temp = text.substr(pos1, 4);
                if (temp.compare("NULL") == 0)
                {
                    SetConsoleTextAttribute(hout, 0x8);
                    cout << "NULL";
                    pos1 += 4;
                }
                else
                    goto NORMAL;
            }
            else
                goto NORMAL;
        }
        else if (ch >= '0' && ch <= '9')
        {
            if (text.length() - pos1 >= 4)
            {
                if (text.substr(pos1 + 1, 1).compare("x") == 0)
                {
                    if (text.substr(pos1 + 3, 1).compare("[") == 0)
                    {
                        SetConsoleTextAttribute(hout, 0x9);
                        cout << text.substr(pos1, 3);
                        pos1 += 3;
                    }
                    else
                        goto NORMAL;
                }
                else if (text.substr(pos1 + 3, 1).compare("{") == 0)
                {
                    SetConsoleTextAttribute(hout, 0xC);
                    cout << text.substr(pos1, 3);
                    pos1 += 3;
                }
                else
                    goto NORMAL;
            }
            else
                goto NORMAL;
        }
        else if (ch == '(')
        {
            pos2 = Findall(")", line, pos1 + 1);
            pos3 = Findall("(", line, pos1 + 1);
            if (pos2 == -1 || (pos3 < pos2 && pos3 != -1))
                SetConsoleTextAttribute(hout, 4);
            else
                SetConsoleTextAttribute(hout, 0xA);
            cout << ch;
            pos1 += 1;
        }
        else if (ch == '[')
        {
            pos2 = Findall("]", line, pos1 + 1);
            pos3 = Findall("[", line, pos1 + 1);
            if (pos2 == -1 || (pos3 < pos2 && pos3 != -1))
                SetConsoleTextAttribute(hout, 4);
            else
                SetConsoleTextAttribute(hout, 0xA);
            cout << ch;
            pos1 += 1;
        }
        else if (ch == '{')
        {
            pos2 = Findall("}", line, pos1 + 1);
            pos3 = Findall("{", line, pos1 + 1);
            if (pos2 == -1 || (pos3 < pos2 && pos3 != -1))
                SetConsoleTextAttribute(hout, 4);
            else
                SetConsoleTextAttribute(hout, 0xA);
            cout << ch;
            pos1 += 1;
        }
        else if (ch == ')' || ch == ']' || ch == '}')
        {
            SetConsoleTextAttribute(hout, 0xA);
            cout << ch;
            pos1 += 1;
        }
        else if (ch == '|' || ch == ',')
        {
            SetConsoleTextAttribute(hout, 0x9);
            cout << ch;
            pos1 += 1;
        }
        else if (ch == '#')
        {
            pos2 = text.find('}', pos1);
            pos3 = text.find(',', pos1);
            pos4 = text.find('/', pos1);
            pos5 = text.find(')', pos1);
            vector<int> compare;
            compare.clear();
            if (pos2 != -1)
                compare.push_back(pos2);
            if (pos3 != -1)
                compare.push_back(pos3);
            if (pos4 != -1)
                compare.push_back(pos4);
            if (pos5 != -1)
                compare.push_back(pos5);
            if (compare.size() == 0)
                goto NORMAL;
            else
            {
                pos2 = compare[0];
                for (int i = 1; i < compare.size(); i++)
                {
                    if (compare[i] < pos2)
                        pos2 = compare[i];
                }
                temp = text.substr(pos1, pos2 - pos1);
            }
            compare.clear();
            string temp_ = temp.substr(1);
            if (temp_.length() == 3)
            {
                int line_, index_;
                pos2 = Findall("]", line, pos1, &line_, &index_);
                pos2 = rFindall(temp_ + '{', line_ - 1, index_);
                pos3 = rFindall("[", line, pos1, &line_, &index_);
                pos3 = Findall(temp_ + '{', line_ - 1, index_);
                if (pos2 != -1 && pos3 != -1)
                    SetConsoleTextAttribute(hout, 0xC);
                else
                    SetConsoleTextAttribute(hout, 0x4);
                cout << temp.c_str();
                pos1 += temp.length();
            }
            else if (temp_.length() == 6)
            {
                int line_, index_, line__, index__;
                pos2 = Findall(temp_.substr(0, 3) + '[', 0, 0, &line_, &index_);
                if (pos2 == -1)
                    SetConsoleTextAttribute(hout, 0x4);
                else
                {
                    pos3 = Findall("[", line_ - 1, index_, &line__, &index__);
                    pos3 = Findall(temp_.substr(3, 3) + '{', line__ - 1, index__);
                    pos4 = Findall("]", line_ - 1, pos1, &line__, &index__);
                    pos4 = rFindall(temp_.substr(3, 3) + '{', line__ - 1, index__);
                    if (pos3 != -1 && pos4 != -1 && pos3 == pos4)
                        SetConsoleTextAttribute(hout, 0xC);
                    else
                        SetConsoleTextAttribute(hout, 0x4);
                }
                cout << temp.c_str();
                pos1 += temp.length();
            }
            else
            {
                cout << ch;
                pos1 += 1;
            }
        }
        else if (ch == ':')
        {
            if (text.length() - pos1 >= 6)
            {
                temp = text.substr(pos1 + 1, 6);
                if (temp.compare("exit()") == 0)
                {
                    SetConsoleTextAttribute(hout, 0x6);
                    cout << ":";
                    SetConsoleTextAttribute(hout, 0x8);
                    cout << "exit";
                    pos1 += 5;
                    continue;
                }
            }
            if (text.length() - pos1 >= 4)
            {
                if (text.substr(pos1 + 1, 4).compare("ran(") == 0)
                {
                    int _line, _index;
                    SetConsoleTextAttribute(hout, 0x6);
                    cout << ":";
                    pos2 = Findall(")", line, pos1, &_line, &_index);
                    if (pos2 != -1)
                    {
                        pos2 = rFindall("#", _line - 1, _index, &_line, &_index);
                        if (pos2 == -1 || (_index < pos1 && _line - 1 == line) || _line - 1 < line)
                            SetConsoleTextAttribute(hout, 0x4);
                        else
                            SetConsoleTextAttribute(hout, 0x8);
                    }
                    else
                        SetConsoleTextAttribute(hout, 0x8);
                    cout << "ran";
                    pos1 += 4;
                    continue;
                }
            }
            if (text.length() - pos1 >= 1)
            {
                temp = text.substr(pos1 + 1, 1);
                if (temp != "#")
                    SetConsoleTextAttribute(hout, 0x4);
                else
                    SetConsoleTextAttribute(hout, 0x6);
            }
            cout << ch;
            pos1 += 1;
        }
        else if (ch == '/')
        {
            SetConsoleTextAttribute(hout, 0x9);
            cout << ch;
            pos1 += 1;
        }
        else
        {
        NORMAL:
            SetConsoleTextAttribute(hout, 0xF);
            cout << ch;
            pos1 += 1;
        }
    }
}

void PrintText(int line = nowline, int all = 0, int check = 0)
{
    if (all == 1)
    {
        //system("cls");
        int n = lines - upline >= 44 ? 45 : lines, i;
        for (i = line; i < upline + n; i++)
        {
            setCur(2, i - upline + 1);
            SetConsoleTextAttribute(hout, 0x8);
            printf("%3d ", i);
            cout << "                                                                                                                                                           ";
            setCur(6, i - upline + 1);
            Colorit(fulltext[i - 1], i - 1);
        }
        setCur(0, i - upline + 1);
        cout << "                                                                                                                                                           ";
        SetConsoleTextAttribute(hout, 0x9);
        if (upline > 1)
        {
            setCur(0, 1);
            cout << "▲";
        }
        if (lines > upline + 44)
        {
            setCur(0, 45);
            cout << "▼";
        }
        if (check == 1)
        {
            //system("cls");
            checktext.clear();
            for (i = 1; i <= fulltext.size(); i++)
            {
                Check(fulltext[i - 1], i - 1);
            }
            SetConsoleTextAttribute(hout, 0xC);
            n = checktext.size() < 5 ? checktext.size() : 5;
            for (i = 0; i < 5; i++)
            {
                setCur(6, 47 + i);
                cout << "                                                                                                    ";
            }
            for (i = 0; i < n; i++)
            {
                setCur(6, 47 + i);
                cout << checktext[i];
            }
        }
        SetConsoleTextAttribute(hout, 0xF);
    }
    else
    {
        setCur(6, line - upline + 1);
        cout << "                                                                                                                                                           ";
        setCur(6, line - upline + 1);
        Colorit(fulltext[line - 1], line - 1);
    }
}

void Create_Inin(int isnew = 1)
{
    system("mode con cols=160 lines=54");
    SetConsoleTitle("Create");
    //draw_form(3, 0, 80, 45, "35", 15);
    if (isnew == 1)
    {
        lines = 4;
        upline = 1;
        nowline = 3;
        nowcol = 4;
        nowline_cols = 33;
        fulltext.clear();
        fulltext.push_back("Begin(New story)");
        fulltext.push_back("0xA[");
        fulltext.push_back("001{NULL|repeat1|Sentence1:#0xA001}]");
        fulltext.push_back("End(#0xA001)");
        PrintText(1, 1);
        setCur(4 + 6, 3);
    }
    else
    {
        ifstream file(Filename, ios::in);
        fulltext.clear();
        char buffer[500];
        while (!file.eof())
        {
            file.getline(buffer, 500);
            fulltext.push_back(buffer);
        }
        lines = fulltext.size();
        nowline = 1;
        nowcol = 1;
        upline = 1;
        nowline_cols = fulltext[1].size();
        PrintText(1, 1);
        setCur(0 + 6, 1);
    }
}

void Type()
{
    int word, changeline, change;
    while ((word = getch()) != 27)
    {
        change = 0;
        changeline = 0;
        if (word == 224)
        {
            word = getch();
            if (word == 72) //up
            {
                if (nowline > 1)
                    nowline--;
                nowline_cols = fulltext[nowline - 1].size();
                if (nowline < upline)
                {
                    upline--;
                    change = 1;
                }
                if (nowcol > nowline_cols)
                    nowcol = nowline_cols;
            }
            else if (word == 80) //down
            {
                if (nowline < lines)
                    nowline++;
                if (nowline > upline + 44)
                {
                    upline++;
                    change = 1;
                }
                nowline_cols = fulltext[nowline - 1].size();
                if (nowcol > nowline_cols)
                    nowcol = nowline_cols;
            }
            else if (word == 75) //left
            {
                if (nowcol > 0)
                    nowcol--;
                else if (nowline > 1)
                {
                    nowline--;
                    if (nowline < upline)
                    {
                        upline--;
                        change = 1;
                    }
                    nowline_cols = fulltext[nowline - 1].size();
                    nowcol = nowline_cols;
                }
            }
            else if (word == 77) //right
            {
                if (nowcol < nowline_cols)
                    nowcol++;
                else if (nowline < lines)
                {
                    nowcol = 0;
                    nowline++;
                    if (nowline > upline + 44)
                    {
                        upline++;
                        change = 1;
                    }
                    nowline_cols = fulltext[nowline - 1].size();
                }
            }

            if (change == 1)
                PrintText(upline, 1);
        }
        else if (word == 0)
        {
            word = getch();
            if (word == 67)
            {
                ofstream file(Filename, ios::out);
                for (int i = 0; i < fulltext.size() - 1; i++)
                {
                    file << fulltext[i];
                    file << '\n';
                }
                file << fulltext[lines - 1];
                file.close();
                SetConsoleTitle("Create");
            }
            else if (word == 63)
                PrintText(upline, 1, 1);
            else if (word == 68)
            {
                autoRepair();
                PrintText(upline, 1);
                SetConsoleTitle("Create*");
            }
        }
        else
        {
            if (word == 13) //enter
            {
                fulltext.insert(fulltext.begin() + nowline, fulltext[nowline - 1].substr(nowcol));
                fulltext[nowline - 1].erase(fulltext[nowline - 1].begin() + nowcol, fulltext[nowline - 1].end());
                lines++;
                nowline++;
                if (nowline > upline + 44)
                {
                    upline++;
                    change = 1;
                }
                nowline_cols = fulltext[nowline - 1].size();
                nowcol = 0;
                changeline = 2;
                SetConsoleTitle("Create*");
            }
            else if (word == 8) //back
            {
                if (nowcol == 0)
                {
                    if (nowline > 1)
                    {
                        nowcol = fulltext[nowline - 2].size();
                        fulltext[nowline - 2] += fulltext[nowline - 1];
                        fulltext.erase(fulltext.begin() + nowline - 1);
                        nowline--;
                        lines--;
                        if (nowline < upline)
                        {
                            upline--;
                            change = 1;
                        }
                        nowline_cols = fulltext[nowline - 1].size();
                        changeline = 1;
                        SetConsoleTitle("Create*");
                    }
                }
                else
                {
                    fulltext[nowline - 1].erase(nowcol - 1, 1);
                    nowcol--;
                    nowline_cols--;
                }
                SetConsoleTitle("Create*");
            }
            else
            {
                if (nowline_cols < 150)
                {
                    fulltext[nowline - 1].insert(fulltext[nowline - 1].begin() + nowcol, word);
                    nowcol++;
                    nowline_cols++;
                    SetConsoleTitle("Create*");
                }
            }
            if (change == 1)
                PrintText(upline, 1);
            else if (changeline != 0)
                PrintText(nowline - changeline + 1, 1);
            else
                PrintText();
            /*
            if (changeline == 0)
                PrintText();
            else
                PrintText(nowline - changeline + 1, 1);
                */
        }
        setCur(nowcol + 6, nowline - upline + 1);
    }
    ofstream file(Filename, ios::out);
    if (file)
    {
        for (int i = 0; i < fulltext.size() - 1; i++)
        {
            file << fulltext[i];
            file << '\n';
        }
        file << fulltext[lines - 1];
        file.close();
    }
}
int main()
{
BEGIN:
    Inin();
    char key;
    string s;
    while ((key = getch()) != 27)
    {
        if (getstring == 0)
        {
            if (key == 9)
            {
                focusNext();
            }
            if ((key == 'R' || key == 'r') && gamestart == 1)
            {
                system("cls");
                altext.clear();
                draw_form(0, 0, 60, 40, "25", 15);
                choose("#0xA001");
                gamestart = 1;
            }
            if (key == 13)
            {
                if (gamestart == 0)
                {
                    switch (button_focus)
                    {
                    case 0:
                        getstring = 1;
                        draw_form(10, 18, 40, 2, "", 15);
                        setCur(11, 19);
                        cin >> Filename;
                        if (ReadSourse(&s) == -1)
                        {
                            Sleep(2000);
                            Inin();
                            break;
                        }
                        else
                        {
                            Sleep(1000);
                            system("cls");
                            draw_form(0, 0, 60, 40, "25", 15);
                            choose(s);
                        }
                        getstring = 0;
                        gamestart = 1;
                        break;
                    case 1:
                        getstring = 1;
                        draw_form(10, 18, 40, 2, "", 15);
                        setCur(11, 19);
                        cin >> Filename;
                        Create_Inin();
                        Type();
                        getstring = 0;
                        Inin();
                        break;
                    case 2:
                        getstring = 1;
                        draw_form(10, 18, 40, 2, "", 15);
                        setCur(11, 19);
                        cin >> Filename;
                        oncoding = 1;
                        Create_Inin(0);
                        Type();
                        oncoding = 0;
                        getstring = 0;
                        Inin();
                        break;
                    case 3:
                        for (int i = 0; i < Big_num; i++)
                            delete[] Bigblock[i];
                        delete[] button;
                        exit(0);
                        break;
                    }
                }
                else
                {
                    string *temp;
                    temp = Depart(button[button_focus].text, ':');
                    altext.insert(altext.begin(), "1," + temp[0]);
                    Draw();
                    if (temp[1] == "exit()")
                    {
                        altext.insert(altext.begin(), "2,game end!(esc to exit|R key to restart)");
                        Draw();
                        gamestart = 0;
                        while ((key = getch()) != 27)
                        {
                            if (key == 'R' or key == 'r')
                            {
                                break;
                            }
                        }
                        if (key == 'R' || key == 'r')
                        {
                            system("cls");
                            altext.clear();
                            draw_form(0, 0, 60, 40, "25", 15);
                            choose("#0xA001");
                            gamestart = 1;
                        }
                        else
                            Inin();
                    }
                    else if (temp[1].substr(0, 4) == "ran(")
                    {
                        int n;
                        temp = Depart(temp[1].substr(4, temp[1].length() - 5), '/', &n);
                        choose(temp[rand() % (n + 1)]);
                    }
                    else
                    {
                        choose(temp[1]);
                    }
                }
            }
        }
    }
    if (gamestart == 1)
    {
        ofstream file(Filename, ios::in | ios::ate);
        if (file)
        {
            file.seekp(-7, ios::end);
            file.write(Blockname[glo_pos].c_str(), 3);
            file.write(nowpos.c_str(), 3);
            file.close();
        }
        goto BEGIN;
    }
}
