#include "mylib.cpp"
#include <ctime>
//====================//=====================//====================//=====================//
char T_Rex[2][3] = {

        '.', '^', '.',
        '|', '-', '|',
}; // vẽ tàu
//====================//=====================//====================//=====================//
int xT_Rex = 25; // tọa độ x của tàu
int yT_Rex = 25; // tọa độ y của tàu
// int xDan = 0;  //tọa độ x đạn
// int yDan = 0; // tọa độ y đạn
int xVatThe = 15; // tọa độ x quái...
int yVatThe = 0;
int score = 0;
int hp = 1;
//====================//=====================//====================//=====================//
void drawT_Rex();  // vẽ tàu 
void drawVatThe(); // vẽ quái vật
void drawBullet(); // vẽ đạn 
//====================//=====================//====================//=====================//
void eraseT_Rex(); // xóa tàu
void eraseVatThe(); // xóa quái vật
// void eraseBullet(); // xóa đạn
//====================//=====================//====================//=====================//
// void moveBullet(); //di chuyển của đạn
// void moveT_Rex(); // di chuyển của tàu
//====================//=====================//====================//=====================//
bool touch(); // kiểm tra đạn có va chạm vào quái vật không
void handle(); // xử lí chính
void handleTouch(); // xử lí các va chạm
void updateScore(); // úp đết điểm
void status();// Hiển thị thông số sau khi thua
//====================//=====================//====================//=====================//
int main(int argc, char const *argv[])
{
    handle(); 
    getch();
    return 0;
}