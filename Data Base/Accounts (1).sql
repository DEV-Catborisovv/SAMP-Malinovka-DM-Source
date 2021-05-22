-- phpMyAdmin SQL Dump
-- version 4.5.4.1deb2ubuntu2.1
-- http://www.phpmyadmin.net
--
-- Хост: localhost
-- Время создания: Май 22 2021 г., 13:59
-- Версия сервера: 5.7.33-0ubuntu0.16.04.1
-- Версия PHP: 7.0.33-0ubuntu0.16.04.16

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- База данных: `gs16275`
--

-- --------------------------------------------------------

--
-- Структура таблицы `Accounts`
--

CREATE TABLE `Accounts` (
  `id` int(10) NOT NULL,
  `name` varchar(24) DEFAULT NULL,
  `password` varchar(30) DEFAULT NULL,
  `Sex` int(1) DEFAULT '0',
  `admin` int(2) DEFAULT '0',
  `reports` int(10) DEFAULT '0',
  `lastday` int(10) DEFAULT '0',
  `lastmounth` int(10) DEFAULT '0',
  `lastyear` int(10) DEFAULT '0',
  `mute` int(14) DEFAULT '0',
  `vmute` int(10) DEFAULT '0',
  `ban` int(1) DEFAULT '0',
  `Level` int(20) DEFAULT '0',
  `Skin` int(10) DEFAULT '0',
  `online` int(10) DEFAULT '0',
  `malinki` int(10) DEFAULT '0',
  `malplus` int(1) DEFAULT '0',
  `priz1` int(1) NOT NULL DEFAULT '0',
  `priz2` int(1) NOT NULL DEFAULT '0',
  `priz3` int(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Индексы сохранённых таблиц
--

--
-- Индексы таблицы `Accounts`
--
ALTER TABLE `Accounts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `id` (`id`);

--
-- AUTO_INCREMENT для сохранённых таблиц
--

--
-- AUTO_INCREMENT для таблицы `Accounts`
--
ALTER TABLE `Accounts`
  MODIFY `id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3035;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
